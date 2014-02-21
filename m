From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH net 5/5] qlcnic: reset firmware API lock during driver
 load
Date: Fri, 21 Feb 2014 19:20:05 +0000
Message-ID: <0EA5B226BC5C7B45A71BF612AA8A019E89AE2589@AVMB1.qlogic.org>
References: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
 <1392963788-18341-6-git-send-email-shahed.shaikh@qlogic.com>
 <5307646D.4050801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60122 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750894AbaBUTUJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 14:20:09 -0500
In-Reply-To: <5307646D.4050801@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Friday, February 21, 2014 6:36 AM
> To: Shahed Shaikh; David Miller
> Cc: netdev; Dept-HSG Linux NIC Dev; Sony Chacko
> Subject: Re: [PATCH net 5/5] qlcnic: reset firmware API lock during driver load
> 
> > From: Sony Chacko <sony.chacko@qlogic.com>
> 
> > Firmware is not resetting API lock at initialization, reset the lock
> > at driver load time.
> 
> > Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> > ---
> > +static void qlcnic_reset_api_lock(struct qlcnic_adapter *adapter) {
> > +	/* Check lock availability*/
> > +	if (qlcnic_api_lock(adapter)) {
> > +		/* Lock not available, force release the lock */
> > +		qlcnic_api_unlock(adapter);
> > +	} else {
> > +		/* Lock available, release it before proceeding */
> > +		qlcnic_api_unlock(adapter);
> > +	}
> 
>     Isn't it simpler to just do:
> 
> 	qlcnic_api_lock(adapter);
> 	qlcnic_api_unlock(adapter);
> WBR, Sergei

Thanks, I will rework this patch.
--Sony
