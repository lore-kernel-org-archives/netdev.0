From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ip_tunnel: disable preemption when updating per-cpu tstats
Date: Thu, 12 Nov 2015 17:25:09 +0100
Message-ID: <1447345509.2333208.438003833.012C1A95@webmail.messagingengine.com>
References: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015, at 16:30, Jason A. Donenfeld wrote:
>  	if (err > 0) {
> -               struct pcpu_sw_netstats *tstats = this_cpu_ptr(stats);
> -
> +               struct pcpu_sw_netstats *tstats;
> +               preempt_disable();
> +               tstats = this_cpu_ptr(stats);

The canonical way is get_cpu_ptr(stats) / put_cpu_ptr.

Bye,
Hannes
