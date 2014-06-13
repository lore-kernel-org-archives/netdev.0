From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [-next] Regression: ssh log in slowdown
Date: Fri, 13 Jun 2014 11:54:00 +0200
Message-ID: <CAMuHMdXOY8NF78gnpqHdNueDKDs5kTZ+xqV+dVXCYCu8MkSFng@mail.gmail.com>
References: <alpine.DEB.2.02.1406130111280.1551@tomh.mtv.corp.google.com>
	<CAMuHMdW4kYeqEby3iABzdbjyAkPKq=x4dyopokFbHWT0Q4fjcw@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1725C134@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725C134@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Jun 13, 2014 at 10:49 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Of Geert Uytterhoeven
> ...
>> Note that I'm also using NFS root, which doesn't seem to be affected.
>> I can happily run "ls -R /" on the serial console during the 10 s delay in ssh.
>
> Are you sure that the delay during ssh login isn't just
> a reverse DNS timeout?

Indeed, the ssh server sends a reverse DNS request twice, with 5s in between:

01:01:16.334257 2e:09:0a:00:6d:85 > 00:0c:42:12:75:1d, ethertype IPv4
(0x0800), length 86: <ssh-server-ip>.55318 > <dns-server-ip>.53: 2907+
PTR? <ssh-client-rev-ip>.in-addr.arpa. (44)
01:01:16.337282 00:0c:42:12:75:1d > 2e:09:0a:00:6d:85, ethertype IPv4
(0x0800), length 114: <dns-server-ip>.53 > <ssh-server-ip>.55318:
2907* 1/0/0 PTR <ssh-client-name>. (72)
01:01:16.356440 2e:09:0a:00:6d:85 > 74:d0:2b:c8:05:49, ethertype IPv4
(0x0800), length 66: <ssh-server-ip>.22 > <ssh-client-ip>.53536: Flags
[.], ack 2194, win 272, options [nop,nop,TS val 4294938665 ecr
480138541], length 0

01:01:21.342072 2e:09:0a:00:6d:85 > 00:0c:42:12:75:1d, ethertype IPv4
(0x0800), length 86: <ssh-server-ip>.55318 > <dns-server-ip>.53: 2907+
PTR? <ssh-client-rev-ip>.in-addr.arpa. (44)
01:01:21.344844 00:0c:42:12:75:1d > 2e:09:0a:00:6d:85, ethertype IPv4
(0x0800), length 114: <dns-server-ip>.53 > <ssh-server-ip>.55318:
2907* 1/0/0 PTR <ssh-client-name>. (72)

01:01:26.353667 2e:09:0a:00:6d:85 > 74:d0:2b:c8:05:49, ethertype IPv4
(0x0800), length 118: <ssh-server-ip>.22 > <ssh-client-ip>.53536:
Flags [P.], seq 1999:2051, ack 2194, win 272, options [nop,nop,TS val
4294939944 ecr 480138541], length 52

Interestingly, I don't see the forward DNS request after that, which
does happen in the
good case.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
