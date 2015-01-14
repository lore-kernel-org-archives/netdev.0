From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [patch net-next 1/2 v3] tc: add BPF based action
Date: Wed, 14 Jan 2015 07:39:34 -0800
Message-ID: <CAMEtUux+HOOegzyi82fYT_JMDX_+d0dZCQ=Zc5GWC-awQmJu1A@mail.gmail.com>
References: <1421229297-14473-1-git-send-email-jiri@resnulli.us> <54B66F08.2010305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:58559 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbbANPj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 10:39:56 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so7476088qgd.3
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 07:39:55 -0800 (PST)
In-Reply-To: <54B66F08.2010305@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 5:28 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
> I'm still wondering about the drop semantics ... wouldn't it be more
> intuitive to use 0 for drops in this context?

good point.
I think it must be 0 to match behavior of socket filters, etc.
If program tries to access beyond packet size or does divide
by zero if will be terminated and will return 0.
So zero should be the safest action from caller point of view.
