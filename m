From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH v2] net: Add Qualcomm IPC router
Date: Wed, 27 Apr 2016 10:14:45 -0700
Message-ID: <20160427171445.GO3202@tuxbot>
References: <1461736085-24862-1-git-send-email-bjorn.andersson@linaro.org>
 <20160427.122242.1614940676503935894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, courtney.cavin@sonymobile.com,
	bjorn.andersson@sonymobile.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160427.122242.1614940676503935894.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 27 Apr 09:22 PDT 2016, David Miller wrote:

> From: Bjorn Andersson <bjorn.andersson@linaro.org>
> Date: Tue, 26 Apr 2016 22:48:05 -0700
> 
> > +	rc = qcom_smd_send(qdev->channel, skb->data, skb->len);
> 
> I truly dislike adding networking protocols that depend upon some
> piece of infrastructure that only some platforms can enable, it's even
> worse when that set of platforms doesn't intersect with x86-64.
> 
> When you do things like this, it's quite hard to make protocol wide
> changes to APIs because build testing becomes an issue.
> 

That's a very valid concern.

> This code can now only be build tested on ARCH_QCOM architectures, and
> that's a serious negative downside.

For normal usage the QRTR_SMD doesn't make much sense to be selectable
unless QCOM_SMD is compiled in, but I can fix up the QCOM_SMD exports
and slap a COMPILE_TEST on it.


Looking at it again, we already have the conditional for QRTR and the OF
code in the driver went away a while back, so we're down to something
like:

	depends on QCOM_SMD || COMPILE_TEST

Regards,
Bjorn
