From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net-next v2 1/2] xen-netback: add a
 vif-is-connected flag
Date: Mon, 23 Sep 2013 08:51:23 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0110351@AMSPEX01CL01.citrite.net>
References: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
 <1379685460-25032-2-git-send-email-paul.durrant@citrix.com>
 <523E5C63.9080804@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17253 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab3IWIv3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 04:51:29 -0400
In-Reply-To: <523E5C63.9080804@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: annie li [mailto:annie.li@oracle.com]
> Sent: 22 September 2013 03:57
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xen.org; Wei Liu; David Vrabel;
> Ian Campbell
> Subject: Re: [Xen-devel] [PATCH net-next v2 1/2] xen-netback: add a vif-is-
> connected flag
> 
> 
> On 2013-9-20 21:57, Paul Durrant wrote:
> > Having applied my patch to separate vif disconnect and free, I ran into a
> > BUG when testing resume from S3 with a Windows frontend because the
> vif task
> > pointer was not cleared by xenvif_disconnect() and so a double call to this
> > function tries to stop the thread twice.
> Or it is better to do more implements in windows netfront? For example,
> when the windows vm hibernates, disconnect the vif as required by
> netback: connect-> closing-> closed.
> 

S3 != hibernation; that is S4. The backend does not go away when the VM goes into S3 as the domain remains intact. We do go through the correct closing->closed transition on the way down but, because of the way the D3->D0 code in the frontend needs to be generalized, we attempt a second closing->closed transition on the way back up. In the S4 case this ok because we have a fresh backend, but in the S3 case we don't and therefore hit the double-disconnect issue. The fact the backend BUGs in this case clearly shows a vulnerability in the backend and thus that is where the fix needs to be made; the frontend is doing nothing wrong.

  Paul
