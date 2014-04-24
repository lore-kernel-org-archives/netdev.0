From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH 0/6][v2] audit: implement multicast socket for journald
Date: Thu, 24 Apr 2014 09:22:27 -0400
Message-ID: <CACLa4psQyoaZTE7R0qiog_biMKXyeGtLc1AQUuEPtemMYcDCSQ@mail.gmail.com>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
	<cover.1398215388.git.rgb@redhat.com>
	<26389161.vp9iWSVLPX@x2>
	<1398225475.750.7.camel@localhost>
	<5357C2D2.5060700@redhat.com>
	<1398264152.2596.25.camel@flatline.rdu.redhat.com>
	<5357DE12.7040905@redhat.com>
	<1398267458.2562.0.camel@flatline.rdu.redhat.com>
	<5357E1B4.2030705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Paris <eparis@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	linux-audit@redhat.com, SE-Linux <selinux@tycho.nsa.gov>,
	jamal@mojatatu.com, Steve Grubb <sgrubb@redhat.com>,
	David Miller <davem@davemloft.net>
To: Daniel J Walsh <dwalsh@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5357E1B4.2030705@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

They would be equivalent if and only if journald had CAP_AUDIT_READ.

I suggest you take CAP_AUDIT_READ away from journald on systems which
need the secadm/sysadmin split (which is a ridiculously stupid split
anyway, but who am I to complain?)

On Wed, Apr 23, 2014 at 11:52 AM, Daniel J Walsh <dwalsh@redhat.com> wrote:
> Meaning looking at the journal would be equivalent to looking at
> /var/log/audit/audit.log.
>
>
> On 04/23/2014 11:37 AM, Eric Paris wrote:
>> On Wed, 2014-04-23 at 11:36 -0400, Daniel J Walsh wrote:
>>> I guess the problem would be that the sysadm_t would be able to look at
>>> the journal which would now contain the audit content.
>> right.  so include it in the sysadm_secadm bool
>>
>>> On 04/23/2014 10:42 AM, Eric Paris wrote:
>>>> On Wed, 2014-04-23 at 09:40 -0400, Daniel J Walsh wrote:
>>>>> Here are the capabilities we currently give to sysadm_t with
>>>>> sysadm_secadm    1.0.0    Disabled
>>>>>
>>>>>    allow sysadm_t sysadm_t : capability { chown dac_override
>>>>> dac_read_search fowner fsetid kill setgid setuid setpcap linux_immutable
>>>>> net_bind_service net_broadcast net_admin net_raw ipc_lock ipc_owner
>>>>> sys_rawio sys_chroot sys_ptrace sys_pacct sys_admin sys_boot sys_nice
>>>>> sys_resource sys_time sys_tty_config mknod lease audit_write setfcap } ;
>>>>>    allow sysadm_t sysadm_t : capability { setgid setuid sys_chroot }
>>>>>
>>>>>    allow sysadm_t sysadm_t : capability2 { syslog block_suspend } ;
>>>>>
>>>>> cap_audit_write might be a problem?
>>>> cap_audit_write is fine.
>>>>
>>>> syslogd_t (aka journal) is going to need the new permission
>>>> cap_audit_read.  Also, as steve pointed out, someone may be likely to
>>>> want to be able to disable that permission easily.
>>>>
>>>> -Eric
>>>>
>>
>> _______________________________________________
>> Selinux mailing list
>> Selinux@tycho.nsa.gov
>> To unsubscribe, send email to Selinux-leave@tycho.nsa.gov.
>> To get help, send an email containing "help" to Selinux-request@tycho.nsa.gov.
>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
