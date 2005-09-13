From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: Re: 2.613: network write socket problems
Date: Tue, 13 Sep 2005 11:22:52 +0200
Message-ID: <200509131122.53286.bernd.schubert__32000.9905066856$1126604082$gmane$org@pci.uni-heidelberg.de>
References: <200509121739.46172.bernd.schubert@pci.uni-heidelberg.de>
Reply-To: TC-ADMIN@listserv.uni-heidelberg.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200509121739.46172.bernd.schubert@pci.uni-heidelberg.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 12 September 2005 17:39, Bernd Schubert wrote:
> Hello,
>
> on last Friday  we switched on our server to 2.6.13 and today we are
> experiencing problems with our nfs clients.
> In particular I'm talking about the unfs3 daemon, not the kernel nfs
> daemon. Both are running on the server but on different ports, of course. 
> Both are also serving to the same clients, but different directories.
>
> Today it already several times happend that the unfs3 daemon stalled.
> Ethereal showed no network packages on the unfs3 daemon port during this
> time. A strace to the proc-id of the daemon clearly shows that *some*
> writes to some network sockets will take ages to finish
>
> write(37, "\200\0\0x\203\326(\5\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 124)
> = 124

Sorry for the noise, its not a kernel problem. Switching back to 2.6.11 didn't 
help, so we investigated further. It turned out, that one of our clients was 
in a kind of a zombie state and asking for filehandles, but not answering 
request from the server. Since unfs3 is only single threaded, all other 
clients had to wait for timeouts.

Bernd
