From: Peter Bieringer <pb@bieringer.de>
Subject: Re: Major deadlock: unregister_netdevice: waiting for <device> to
 become free. Usage count = 1
Date: Sun, 26 Dec 2004 10:26:28 +0100
Message-ID: <A3A6D3E15EE6197D77408F1A@t1mobil.muc.aerasec.de>
References: <8A6334DE39BB61513FFBD614@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist USAGI-users <usagi-users@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>
In-Reply-To: <8A6334DE39BB61513FFBD614@t1mobil.muc.aerasec.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi again,

--On Sonntag, Dezember 26, 2004 10:14:10 +0100 Peter Bieringer 
<pb@bieringer.de> wrote:

> Kernel tells me each some seconds:
>
> Dec 26 09:59:10 * kernel: unregister_netdevice: waiting for sit_sixxs to
> become free. Usage count = 1
> Dec 26 09:59:50 * last message repeated 4 times
> Dec 26 10:01:00 * last message repeated 7 times
> Dec 26 10:02:10 * last message repeated 7 times
> Dec 26 10:03:20 * last message repeated 7 times

During further process killing by hand suddenly the problem was solved.

My last commands:
  422  kill -9 5506
  437  kill -9 5506
  587  kill 23837
  589  kill -9 15765 14675 14429 14430 14483
  590  kill -9 15765 14675 14429 14430 14483
  592  kill -9 12243
  593  kill -9 12243
  595  kill 11808 3880 23933 11739
  596  service xfs stop
  597  service privoxy stop
  598  kill -9 2673
  603  kill -9 5506
  604  kill -9 2902

Because I often try to kill the hanging "ip tunnel del" command, I believe, 
one of the other network processes block something:

>  2673 ?        Ss     0:01 rpc.statd

>  2902 ?        Ssl    0:00 /usr/sbin/named -u named

>  5506 ?        R     43:49 /sbin/ip tunnel del sit_sixxs

If happen next, I will check netstat to find more indicators which causes 
the problem.

Anyway, such deadlock is not nice and doesn't appear in earlier kernel.

	Peter
-- 
Dr. Peter Bieringer                        http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                  mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member     http://www.deepspace6.net/
