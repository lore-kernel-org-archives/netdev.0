From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 15:55:33 -0400
Message-ID: <CAHC9VhRjjWk9drwY5Db2Zwu1CHw+dxtkMKR6Ovw3pzuHBvieVQ@mail.gmail.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	<5715EBCF.20801@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
	jhs@mojatatu.com, davem@davemloft.net, tgraf@suug.ch,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:32814 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbcDSTze convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 15:55:34 -0400
Received: by mail-oi0-f66.google.com with SMTP id f63so2678944oig.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 12:55:34 -0700 (PDT)
In-Reply-To: <5715EBCF.20801@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 4:26 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> + selinux maintainers
>
> Le 18/04/2016 23:10, Roopa Prabhu a =C3=A9crit :
> [snip]
>>
>> diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab=
=2Ec
>> index 8495b93..1714633 100644
>> --- a/security/selinux/nlmsgtab.c
>> +++ b/security/selinux/nlmsgtab.c
>> @@ -76,6 +76,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =3D
>>         { RTM_NEWNSID,          NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
>>         { RTM_DELNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  },
>>         { RTM_GETNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  },
>> +       { RTM_NEWSTATS,         NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
>
> I would say it's NETLINK_ROUTE_SOCKET__NLMSG_READ, not WRITE. This co=
mmand
> is only sent by the kernel, not by the userland.

=46rom what I could tell from the patch description, it looks like
RTM_NEWSTATS only dumps stats to userspace and doesn't alter the state
of the kernel, is that correct?  If so, then yes, NLMSG__READ is the
right SELinux permission.  However, if RTM_NEWSTATS does alter the
state/configuration of the kernel then we should use NLMSG__WRITE.

--=20
paul moore
www.paul-moore.com
