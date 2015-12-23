From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH 00/17] CALIPSO implementation
Date: Wed, 23 Dec 2015 13:07:42 -0500
Message-ID: <CAHC9VhQDzu0Mw6zAYEbMjy9ROCxG6_O5PsxjDhDZzEyw5qxP6w@mail.gmail.com>
References: <1450784813-18304-1-git-send-email-huw@codeweavers.com>
	<56798845.6050703@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Casey Schaufler <casey@schaufler-ca.com>,
	Huw Davies <huw@codeweavers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34232 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964956AbbLWSHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 13:07:43 -0500
Received: by mail-oi0-f41.google.com with SMTP id o124so127344511oia.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 10:07:43 -0800 (PST)
In-Reply-To: <56798845.6050703@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 12:28 PM, Casey Schaufler
<casey@schaufler-ca.com> wrote:
> On 12/22/2015 3:46 AM, Huw Davies wrote:
>> This patch series implements RFC 5570 - Common Architecture Label IPv6
>> Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
>> on IPv6 packets using a hop-by-hop option.  CALIPSO very similar to
>> its IPv4 cousin CIPSO and much of this series is based on that code.
>
> There's a one line change to the Smack code in 15/17 due to
> a change in the api, but I assume that there has been no
> attempt to verify that this works with Smack. It's not 100%
> clear that this won't break a Smack kernel, but I haven't
> tried it.
>
> You'll need to provide sufficient information (or code!) so
> that security modules other than SELinux can use this. If
> you look at how Smack uses netlabel for IPv4 you will see
> that it differs substantially from the way SELinux uses it.

Smack is going to have some difficulties implementing CALIPSO due to
some previous design decisions and inconsistencies between how Smack
handles both IPv4 and IPv6 packet labeling today.  I think we can all
agree that asking Huw to resolve these problems isn't quite fair,
although asking Huw to make sure he doesn't break existing
functionality *is* fair, and a requirement for patch acceptance.

Huw, I would suggest you ensure that the NetLabel/CALIPSO changes
don't break the existing Smack code, and that everything is commented
appropriately.  Adding CALIPSO support to the netlbl_cfg_*() functions
in netlabel_kapi.c would also be a good idea, and shouldn't be too
difficult (I should have commented on this earlier, my mistake).
However, I think resolving the Smack IPv6 design issues is something
best left to Casey and the rest of the Smack developers.

> Thank you for tackling RFC 5570. The lack of something like
> this has put IPv6 at a real disadvantage.

Agreed, thanks Huw for all the hard work you put into this
implementation.  I started a similar effort on two separate occasions
but never had the time to see it through to the end; I'm happy that
someone was finally able to get it finished.

-- 
paul moore
www.paul-moore.com
