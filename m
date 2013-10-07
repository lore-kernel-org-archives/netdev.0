From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCHv1 net] xen-netback: transition to CLOSED when removing
 a VIF
Date: Mon, 7 Oct 2013 14:57:37 +0100
Message-ID: <5252BDD1.1000301@citrix.com>
References: <1381150519-14557-1-git-send-email-david.vrabel@citrix.com> <20131007134314.GD28411@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, Ian Campbell <ian.campbell@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:8177 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab3JGN5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 09:57:40 -0400
In-Reply-To: <20131007134314.GD28411@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/13 14:43, Wei Liu wrote:
> On Mon, Oct 07, 2013 at 01:55:19PM +0100, David Vrabel wrote:
>> From: David Vrabel <david.vrabel@citrix.com>
>>
>> If a guest is destroyed without transitioning its frontend to CLOSED,
>> the domain becomes a zombie as netback was not grant unmapping the
>> shared rings.
>>
>> When removing a VIF, transition the backend to CLOSED so the VIF is
>> disconnected if necessary (which will unmap the shared rings etc).
>>
>> This fixes a regression introduced by
>> 279f438e36c0a70b23b86d2090aeec50155034a9 (xen-netback: Don't destroy
>> the netdev until the vif is shut down).
>>
> 
> Is this regression solely caused by 279f438e36c or caused by both
> ea732dff5c and 279f438e36c? I ask because you make use of the new state
> machine introduced in ea732dff5c. Or are you simply using the new state
> machine to fix the regression instead of going back to old code?

I bisected it to 279f438.  I'm just using the handy new state machine to
fix it.

David
