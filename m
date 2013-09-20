From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Fri, 20 Sep 2013 18:18:02 +0200
Message-ID: <523C753A.8040401@suse.cz>
References: <523C5141.4080608@suse.cz>	<20130920.115634.1931451843075283025.davem@davemloft.net>	<523C7464.3070007@suse.cz> <20130920.121535.1653382964468102292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, akpm@linux-foundation.org, jeffm@suse.com,
	netdev@vger.kernel.org, isdn4linux@koppen.de, isdn@linux-pingi.de,
	sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:59750 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab3ITQSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:18:06 -0400
Received: by mail-ea0-f173.google.com with SMTP id g10so377051eak.18
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:18:04 -0700 (PDT)
In-Reply-To: <20130920.121535.1653382964468102292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2013 06:15 PM, David Miller wrote:
> From: Jiri Slaby <jslaby@suse.cz>
> Date: Fri, 20 Sep 2013 18:14:28 +0200
> 
>> On 09/20/2013 05:56 PM, David Miller wrote:
>>> From: Jiri Slaby <jslaby@suse.cz>
>>> Date: Fri, 20 Sep 2013 15:44:33 +0200
>>>
>>>> On 09/15/2013 01:28 AM, Ben Hutchings wrote:
>>>>>> @@ -694,6 +699,10 @@ base_sock_ioctl(struct socket *sock, uns 
>>>>>> case IMSETDEVNAME: { struct mISDN_devrename dn; +		if
>>>>>> (!capable(CAP_SYS_ADMIN) && +				!gid_eq(misdn_permitted_gid,
>>>>>> current_gid()) && +				!in_group_p(misdn_permitted_gid)) +
>>>>>> return -EPERM; if (copy_from_user(&dn, (void __user *)arg, 
>>>>>> sizeof(dn))) { err = -EFAULT;
>>>>>
>>>>> This seems to be the important bit: renaming of devices (if allowed
>>>>> at all) ought to be limited to CAP_SYS_ADMIN or possibly
>>>>> CAP_NET_ADMIN. But why should the group that is allowed to use
>>>>> mISDN data sockets also be allowed to do this?
>>>>
>>>> This is based on an old patch we are dragging in SUSE since 2009:
>>>> http://www.isdn4linux.de/pipermail/isdn4linux/2009-December/004493.html
>>>> https://bugzilla.novell.com/show_bug.cgi?id=564423
>>>>
>>>> The whole point of the gid-based access was to still allow some user
>>>> group to manipulate the device in an arbitrary way.
>>>>
>>>> So if everybody agrees I will just disallow rename to
>>>> non-CAP_NET_ADMIN users and we are done?
>>>
>>> No we are not done, sorry.
>>>
>>> Having a device specific module parameter for this is wrong on several
>>> fundamental levels.
>>
>> What I'm suggesting is just to put a !capable(CAP_NET_ADMIN) test into
>> the rename path and nothing more.
> 
> And I'm saying that regardless of such a change, the patch itself
> is fundamentally implemented incorrectly and not acceptable for
> upstream inclusion until the interface for configuration is changed.

Ok, let's leave the hole in there then.

-- 
js
suse labs
