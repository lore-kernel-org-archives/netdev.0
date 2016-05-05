From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 08/15] i40e: Allow user to change input set mask for
 flow director
Date: Wed, 4 May 2016 20:52:35 -0700
Message-ID: <CAKgT0Ud1rybBL9y9OvnR2saMZfMBwb2RFBYgukGBFsa=hHwsOA@mail.gmail.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1461704148-114349-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Kiran Patil <kiran.patil@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@redhat.com>, sassmann@redhat.com,
	John Greene <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36672 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284AbcEEDwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:52:36 -0400
Received: by mail-ig0-f182.google.com with SMTP id u10so4945616igr.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:52:35 -0700 (PDT)
In-Reply-To: <1461704148-114349-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 1:55 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Kiran Patil <kiran.patil@intel.com>
>
> This patch implements feature, which allows user to change
> input set mask for flow director using side-band channel.
> This patch adds definition of FLOW_TYPE_MASK into the header file.
> With this patch, user can now specify less than 4 tuple(src ip, dsp ip,
> src port, dst port) for flow type TCP4/UDP4.

Isn't that what the mask field in the flow specifier is for?  It seems
like you guys are trying to come up with your own alternative to how
this has been done in the past.  It looks like this driver is badly
broken and it isn't implementing flow director.  It is implementing a
bad hack that is trying to pass itself off as flow director.

I don't know who thought it was okay to come up with your own
interpretation on how the fields are supposed to be used but whoever
did it made a real mess of things.  I am pretty sure the ixgbe driver
and the i40e driver are playing by two completely different rule
books.  If you printed an i40e rule and tried to apply it to ixgbe it
just wouldn't work because you guys didn't do basic things like
actually use the mask fields, in the other direction you guys totally
ignored the mask fields which really isn't okay because you should
throw an error if someone tries to get the driver to do something it
cannot support.

I'd say you are better off scrapping this whole patch and fixing flow
director so that you actually use the mask fields correctly because
the current implementation is badly broken and breaking it further
isn't going to help.  You need to add support for validating the mask
fields to the driver and that will solve the original problem that
this patch is attempting to work around.

- Alex
