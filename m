From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] geneve: restore vlan bits in xmit path
Date: Thu, 17 Sep 2015 15:02:13 -0700
Message-ID: <CALnjE+oUjh_55sFYAXTADfGyLZ2uBE5+7qiFRJtbgrHnoHza8Q@mail.gmail.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
	<CALnjE+r9A0bUmF-ZEvUdhop2kD7VGQYpn0PKG23cCU9qcrUrVQ@mail.gmail.com>
	<20150917192534.GE25806@tuxdriver.com>
	<CAEP_g=8v__N59dKe1wUfgHDjgrvGzXWN4AJ=ifeuxxn_FNmDQQ@mail.gmail.com>
	<20150917201545.GF25806@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:32790 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbbIQWCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 18:02:14 -0400
Received: by igbkq10 with SMTP id kq10so23107370igb.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 15:02:13 -0700 (PDT)
In-Reply-To: <20150917201545.GF25806@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 1:15 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Thu, Sep 17, 2015 at 12:48:56PM -0700, Jesse Gross wrote:
>> On Thu, Sep 17, 2015 at 12:25 PM, John W. Linville
>> <linville@tuxdriver.com> wrote:
>> > On Thu, Sep 17, 2015 at 11:45:58AM -0700, Pravin Shelar wrote:
>> >> On Thu, Sep 17, 2015 at 10:18 AM, John W. Linville
>> >> <linville@tuxdriver.com> wrote:
>> >> > These seem to have been accidentally dropped in commit 371bd1061d29
>> >> > ("geneve: Consolidate Geneve functionality in single module.").
>> >> >
>> >> Geneve should not export vxlan feature. So that it never sees vxlan
>> >> tagged packets. Can you turn off the vlan feature?
>> >
>> > I'm not sure I understand...?  This is vlan, not vxlan.
>>
>> I think he just mean vlan. If you remove the line where
>> dev->vlan_features are set then the core stack will handle this and we
>> don't need to do anything special here.
>
> Is that preferrable to this patch?  Tunneling vlan-tagged frames
> seems weird, but I would hate to disallow it if some crazy person
> wanted to do that...
>

To support vlan-offload in geneve we end up doing same as networking
stack does in case of software fallback for vlan-offload. So by not
setting the feature, we can avoid the duplicate code in geneve module.

> I guess the other way would slightly improve performance, and this
> could be added back later.  What about the VLAN-related bits in
> dev->features and ->hw_features?  Should they go as well?
>
No need to set vlan feature in any of device features.
