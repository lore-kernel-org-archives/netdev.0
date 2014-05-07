From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Wed, 7 May 2014 16:34:08 -0700
Message-ID: <CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:47213 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbaEGXeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:34:09 -0400
Received: by mail-ve0-f174.google.com with SMTP id jw12so2233003veb.5
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:34:08 -0700 (PDT)
In-Reply-To: <CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 4:01 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> I agree that it should, but it doesn't, and if these patches get
> backported, things will break.  OTOH, if the patches don't get
> backported, things may still break, and we have a possibly rather
> severe unfixed vulnerability.

How did this *use* to work? It looks like it drops permissions after
the bind(), so the actual _IO_ must have always been done without
permissions, no?

Is it just a bind-time permission check that is now failing, because
it uses the credentials associated with the socket open? If so, I'd
suggest unding just the ns-capable change for bind(), and make that
one always use the current process effective one.

If you're a suid application, you're not doing "bind()" on random file
descriptors that were passed to you. It's really just read/write that
need to be careful.

            Linus
