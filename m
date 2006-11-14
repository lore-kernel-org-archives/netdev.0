From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [TG3]: Increase 5906 firmware poll time.
Date: Tue, 14 Nov 2006 18:05:28 -0500
Message-ID: <455A4BB8.8060301@garzik.org>
References: <1163544143.4954.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20691 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965992AbWKNXFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 18:05:32 -0500
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1163544143.4954.19.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [TG3]: Increase 5906 firmware poll time.
> From: Gary Zambrano <zambrano@broadcom.com>
> 
> Newer 5906 bootcode needs about 7ms to finish resetting so the poll
> firmware loop was changed to maximum 20ms.
> 
> Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK, of course, but this brings up something else:  what's the status of 
moving chip reset outside of a spinlock?

Currently a reset during operation can trigger the CPU lockup detector 
and other doo-dads, because you can easily spend a second or two with a 
spinlock held (a loooooong time, to hold a spinlock)

	Jeff


