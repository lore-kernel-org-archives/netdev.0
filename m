From: Ross Biro <ross.biro@gmail.com>
Subject: Re: [PATCH] port_reuse listen fix (allow simultaneous single listen + outgoing connects from same port)
Date: Thu, 9 Dec 2004 10:36:08 -0500
Message-ID: <8783be6604120907367db1fda5@mail.gmail.com>
References: <fcb9aa29041209032521899698@mail.gmail.com>
Reply-To: Ross Biro <ross.biro@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
        =?UTF-8?Q?YOSHIFUJI_Hideaki_/_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>,
        davem@redhat.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>
In-Reply-To: <fcb9aa29041209032521899698@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Dec 2004 13:25:26 +0200, Ilya Pashkovsky
<ilya.pashkovsky@gmail.com> wrote:
> This is the latest patch with removed bool > 1 check and ipv6 support.
> http://puding.mine.nu/patches/
> http://puding.mine.nu/patches/patch-reuse-bool-ipv6
> 
> to check, you can use netcat (sets SO_REUSEADDR by default).
> on one host (host A): nc -v -l -p 9999
> on another/same host (host B): nc -v -l -p 9000
> on host A: nc -v -p 9999 host.B.ip.addr 9000
> on host B: nc -v host.A.ip.addr 9999

What happens if on host B you do 

nc -v -p 9000 host.A.ip.addr 9999?

Seems to me you will break the rule that a connection is uniquely
identified by (srcpip, destip, srcport, destport).

    Ross
