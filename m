From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal tables
Date: Tue, 18 Aug 2015 10:18:51 -0700
Message-ID: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
References: <1439850977-31079-1-git-send-email-sfeldma@gmail.com> <20150818140156.GE4381@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:35993 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbbHRRTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 13:19:36 -0400
Received: by obkg7 with SMTP id g7so15455127obk.3
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 10:19:35 -0700 (PDT)
In-Reply-To: <20150818140156.GE4381@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 7:01 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, Aug 17, 2015 at 03:36:17PM -0700, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> > tree /sys/kernel/debug/rocker
>> /sys/kernel/debug/rocker
>> ????????? 5254001235010000
>>     ????????? fdb_tbl
>>     ????????? internal_vlan_tbl
>>     ????????? neigh_tbl
>>     ????????? of_dpa_flow_tbl
>>     ????????? of_dpa_group_tbl
>>
>> 1 directory, 5 files
>>
>> > cat /sys/kernel/debug/rocker/5254001235010000/internal_vlan_tbl
>> ifindex 5 ref_count 1 vlan 3843
>> ifindex 7 ref_count 2 vlan 3840
>> ifindex 4 ref_count 1 vlan 3842
>>
>> > cat /sys/kernel/debug/rocker/5254001235010000/fdb_tbl
>> learned 1 pport 1 addr 00:02:00:00:02:00 vlan 3840
>> learned 1 pport 2 addr 00:02:00:00:03:00 vlan 3840
>>
>> > cat /sys/kernel/debug/rocker/5254001235010000/neigh_tbl
>> 11.0.0.9 dev sw1p2 ref_count 3 index 1 dst 00:02:00:00:01:00 ttl_check 1
>> 11.0.0.1 dev sw1p1 ref_count 3 index 0 dst 00:02:00:00:00:00 ttl_check 1
>
> Hi Scott
>
> David is not so keen no debugfs stuff. He already NACKed adding more
> than what is currently in DSA:
>
> https://lkml.org/lkml/2015/7/11/8

That patch added writable debugfs files, which I can see might be used
as a back-door to program hardware.  That does seem bad.

> I think the key thing from David's message is:
>
>> Fetching information should be done by well typed, generic,
>> interfaces that apply to any similar device or object.
>
> So rather than splattering rocker stuff in debugfs, we should really
> be thinking about an interface which works well for both Rocker and
> DSA, i.e. generic, and keeps David happy by being typed.
>
> No idea what that actually is, not thought about it yet.

Rocker debugfs files are read-only and dump internal tables that are
very specific to the (rocker) device.  I don't see how these could be
generic as each device/driver will have it's own unique data
structures.

I'm OK with not including debugfs in rocker even for these read-only
files, but I find them very useful during development/debugging, and I
could see their value in troubleshooting issues with others using
rocker.

Writable debugfs files is another story.

-scott
