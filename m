From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: user space checksum
Date: Thu, 26 May 2005 12:47:24 -0700
Message-ID: <20050526124724.57e9bafa@dxpl.pdx.osdl.net>
References: <1116744708.3021.12.camel@raz-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raz ben jehuda <razb@bitband.com>
In-Reply-To: <1116744708.3021.12.camel@raz-laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 22 May 2005 09:51:48 +0300
raz ben jehuda <razb@bitband.com> wrote:

> I do not know if this was ever suggested.so i'll try any way.
> Why not give the user the chance to supply the kernel/card with the
> checksums instead of having the kernel/network card do the work ? 

A bad idea for two reasons:
	* application data units (APDU) do not match transport data units
	  for a stream oriented protocol. 
	* computing checksum is done for almost nothing as part
	  of the copy from user to kernel space. Modern CPU cache's
	  make computation cost << memory access cost.

> This is because a user is aware to the data he sends and he can optimize
> the data checksum calculations more than anyone else. for instance a web
> server sends its html pages, which are static data. it can pre-calculate
> the checksums.

	Tcp will compute different transfer size's based on the congestion
	window of the connection, and header part will be different.
