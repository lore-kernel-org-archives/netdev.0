From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [Intel-wired-lan] [PATCH V3 0/2] pci: Provide a flag to access
 VPD through function 0
Date: Sat, 11 Jul 2015 14:49:40 -0500
Message-ID: <CAErSpo5at=C78JbWEA6YKUNhV4vtUMjSiUKcWG0Ad7Gkg+i2VQ@mail.gmail.com>
References: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com>
 <051B68B4-3E77-4EB0-B9FE-8523631884A2@intel.com> <45099CC7-DDAB-41D9-AB74-5A81E2AAF64C@intel.com>
 <CAErSpo7e-QtQQTj2yh_jG07vqU1j1YBez_9wrcrzOQs7+eDFng@mail.gmail.com>
 <8CB0ECE7-CFE2-43CB-BA60-2E2E0A34D5D1@intel.com> <C468F237-DBA2-4503-BA99-76CC1FC46999@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35389 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbGKTuB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 15:50:01 -0400
Received: by wgjx7 with SMTP id x7so270689882wgj.2
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 12:50:00 -0700 (PDT)
In-Reply-To: <C468F237-DBA2-4503-BA99-76CC1FC46999@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 12:31 PM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>> On Jun 26, 2015, at 11:04 AM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>>
>>> Sorry, Mark, I've just been busy with other issues and haven't had a
>>> chance to look at this yet.
>>
>> Is there any chance of this getting into this merge window?
>
> Well, it has missed the merge window, but this really is a bug fix. These patches address problems that, under race conditions, can corrupt VPD data and under other conditions can cause hangs. In fact I would submit that the reason that the VPD operations have been made interruptible is directly related to hangs caused by the sharing of VPD capability registers between functions. You see, if one function ever performs a VPD write, any subsequent read on any other function that shares those registers will definitely hang.

As a rule, after the merge window closes, I only merge fixes for
things we broke during the merge window or drivers for brand-new
things, where there's no chance of breaking something that used to
work.

It would be nice to have a description of what a user might see when
tripping over this problem and maybe some pointers to problem reports.
I see it fixes concurrent access problems, and I infer that it's
related to sysfs.

Feel free to add a stable tag when you post your patches.  I'll try to
remember to add it when merging this.  When it's relevant, it's nice
to include the SHA1 of the commit that introduced the bug.  But in
this case, I think it's been there "forever."

Bjorn
