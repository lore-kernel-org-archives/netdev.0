From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 10:38:18 +0200
Message-ID: <200610121038.18309.dada1@cosmosbay.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:44176 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1422835AbWJLIiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 04:38:16 -0400
To: "Martin Schiller" <mschiller@tdt.de>
In-Reply-To: <000101c6edd5$a880d430$1a04010a@V505CP>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 October 2006 10:08, Martin Schiller wrote:
> Hi!
>
> I'm searching for a solution to suppress / delay the SYN-ACK packet of a
> listening server (-application) until he has decided (e.g. analysed the
> requesting ip-address or checked if the corresponding other end of a
> connection is available) if he wants to accept the connect request of the
> client. If not, it should be possible to reject the connect request.
>
> My idea is to add two ioctl's:
> 	- One to set the listening socket into "delay_synack" mode.
> 	- And one to send the synack packet, if the connection should be
> accepted.
>
> If the "delay_synack" mode is not enabled, the connection should just work
> as usual.
>
> I had a look at the tcp/ipv4 stack for a while and have found out, that
> this three-way-handshake is already done before anything comes up to
> user-space when I am doing a call to accept(). So I think it wouldn't be
> possible to add this feature with "a little hack".
>

Well, it is already possible to delay the 'third packet' of an outgoing 
connection with a litle hack. But AFAIK not the SYNACK of incoming 
connection. It could be cool. Maybe some new syscalls are needed:

int syn_recv(int socklisten, ...);
/* give to user app the SYN packet */
int syn_ack(int socklisten, ...);
/* User app has the ability to ask kernel tcp stack to :
    DROP this packet.
    REJECT the attempt
    ACCEPT the attempt (sending a SYN/ACK)
*/

Maybe NETLINK (netfilter) is able to meet your need.

> Does anybody have any hints for me where I should start to work?
>
> Regards,
> Martin Schiller
