From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC PATCH v3 0/8] CAIF Protocol Stack
Date: Thu, 3 Dec 2009 18:49:52 +0100
Message-ID: <B299262A5779464A9E3E1766D76FFA23050A0F4724@eseldmw101.eemea.ericsson.se>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <4B169DB0.6010307@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <randy.dunlap@oracle.com>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>
To: "Stefano Babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:52747 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbZLCRts convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 12:49:48 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B169DB0.6010307@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefano,
Thank you for your effort reviewing and testing CAIF. 
I'm exited that you have been able to get into the code 
and that you got the last patch-set  up and running!

Stefano Babic wrote:
> I would like to test your patches with real hardware (based on an ARM
> processor), as I did last time before sending my comments.
Great! Looking forward to hearing your results.
We're doing a lot of testing and bug fixing on this as well, and
I've already found and fixed a couple of bugs. 

> I think it should easier if in the Documentation there is an example
> to explain how to setup a connection, for example with AT protocol.

This was the intention of the example part in caif.man. As mentione below
I will update this in next patch-set. 

> I tried and I get "Specified PHY type does not exists", probably
> because I have not well understood the parameters.
Parameters would probably look like this:

insmod caif_serial.ko ser_ttyname=/dev/ttyS0 ser_loop=no ser_use_stx=no

Most likely you get this error message because something went wrong 
when setting up the serial connection.  At opening, the following 
sequence happends: 
1) caif_serial registers a net device called "caifser0".
2) if caif.ko is insmod'ed caif_dev opens this net device.
3) caif_serial receives open and opens the TTY and registers N_CAIF line discipline. 
4) This causes caif line discipline to be opened. 
I'm not quite sure where this goes wrong. Could be the registration of the N_CAIF ldisc?
I must admit that changing to N_CAIF was a last-minute change, 
I have done most of my testing by hi-jacking N_MOUSE.

> There are some errors in the MAN page documentation (patch #7) and
> the example reported does not compile (for example, CAIFSO_CHANNEL
> should be CAIF_CHANNEL_OPT, and so on). 
OK thanks, I'll fix this in the next patch-set.

> Can you provide an example for the user space to setup a connection ?
[snip]
  int s,r;
  char buf[200],*msg = "AT\r\n";
  struct sockaddr_caif addr = {
    .family = AF_CAIF,
    .u.at.type = CAIF_ATTYPE_PLAIN
  };
  s = socket(AF_CAIF, SOCK_SEQPACKET, CAIFPROTO_AT);
  connect(s, (struct sockaddr *) &addr, sizeof(addr));
  send(s,msg,strlen(msg),0);
  r = recv(s,buf,sizeof(buf),0);
  buf[r]=0;
  printf("buf:'%s'\n",buf);
  
BR/Sjur


 

