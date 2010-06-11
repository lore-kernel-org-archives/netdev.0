From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Fri, 11 Jun 2010 11:53:32 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006111152230.30433@obet.zrqbmnf.qr>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com> <4C08EB85.3050900@trash.net> <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com> <4C0FA24A.7060907@trash.net> <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com> <4C10ACDC.6010108@trash.net>
 <20100610095312.GC1915@jolsa.lab.eng.brq.redhat.com> <4C10B8C8.2050201@trash.net> <20100611081604.GA1739@jolsa.Belkin>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100611081604.GA1739@jolsa.Belkin>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-06-11 10:16, Jiri Olsa wrote:
>
>I prepared the patch implementing IP_NODEFRAG option for IPv4 socket.
>
>Also I just got an idea, that there could be no reassembly if there are
>no rules for connection tracing set.. not sure how can I check that best
>so far.. any idea?
>
>@@ -572,6 +572,14 @@ static int do_ip_setsockopt(struct sock *sk, int level,
> 		}
> 		inet->hdrincl = val ? 1 : 0;
> 		break;
>+	case IP_NODEFRAG:
>+		if (sk->sk_type != SOCK_RAW) {
>+			err = -ENOPROTOOPT;
>+			break;
>+		}
>+		inet->nodefrag = val ? 1 : 0;
>+		printk("IP_NODEFRAG %p -> %d\n", inet, inet->nodefrag);
>+		break;

You want to get rid of this printk otherwise it spews the logs.
