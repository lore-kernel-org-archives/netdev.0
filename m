From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth fixes for 2.6.20-rc4
Date: Mon, 08 Jan 2007 02:19:13 +0100
Message-ID: <1168219153.12025.17.camel@violet>
References: <1168216304.12025.10.camel@violet>
	 <20070107.171123.43392648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:40876 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965289AbXAHBTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jan 2007 20:19:16 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20070107.171123.43392648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > Commit: 2b2e64be763c5e64d4ae4a061825b18decf1edf7 
> > Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:33 +0100 
> > 
> >     [Bluetooth] Fix uninitialized return value for RFCOMM sendmsg()
> >     
> >     When calling send() with a zero length parameter on a RFCOMM socket
> >     it returns a positive value. In this rare case the variable err is
> >     used uninitialized and unfortunately its value is returned.
> >     
> >     Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
> 
> You can't fix this bug like that.
> 
> If sendmsg() sends any bytes, it should return the number of
> bytes sent even if an error occurs mid-stream.
> 
> With this change, you'll now return the error instead of
> the number of bytes sent.  That's what the new "sent = err"
> assignment does.
> 
> You have to do sendmsg() with those semantics, or else you lose
> information in that the user can never know how many bytes were
> actually sent successfully.  Losing the error after successfully sent
> bytes is OK, if the error persists the user will get it when it
> recalls sendmsg() to push the rest of the remaining bytes out.
> 
> The original code tried to do it right.
> 
> If the bug is that 'err' is uninitialized, why try to fix this
> by being fancy, just initialize it :-)

We have "int sent = 0" and exactly that is returned if "len == 0".

Regards

Marcel


