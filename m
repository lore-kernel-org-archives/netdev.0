From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next.git 4/9] stmmac: add the support for PTP hw clock
 driver
Date: Mon, 11 Mar 2013 19:55:38 +0100
Message-ID: <20130311185536.GA2409@netboy.at.omicron.at>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
 <1362653419-1047-5-git-send-email-peppe.cavallaro@st.com>
 <20130310121050.GA2462@netboy.at.omicron.at>
 <CAJ3bTp7n-Y6TYrhDMe58fALtX5O34qifO9khWYXpo-OwnrRKiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, bh74.an@samsung.com
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:38027 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611Ab3CKSzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 14:55:51 -0400
Received: by mail-ea0-f169.google.com with SMTP id z7so1399839eaf.0
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 11:55:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3bTp7n-Y6TYrhDMe58fALtX5O34qifO9khWYXpo-OwnrRKiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 08:37:24PM +0530, Rayagond K wrote:
> On Sun, Mar 10, 2013 at 5:40 PM, Richard Cochran <richardcochran@gmail.com>wrote:

> > Don't you need locking here to protect against concurrent callers of
> > config_addend?
> >
> 
> Yes we need locking here too, will add it.
> 
> But I can see no locking in this function in other two driver'e
> ppt_ixp46x.c and gianfar_ptp.c. So I just followed these two driver.

Those two drivers don't need locking, because setting the addend
register is a single 32 bit write operation in both cases.

In your driver, setting the addend involves a sequence of writes and
reads, in addition to polling a status bit, so you do need to
serialize access to those registers.

Thanks,
Richard
