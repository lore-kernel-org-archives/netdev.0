From: Daniel J Walsh <dwalsh@redhat.com>
Subject: Re: [PATCH 0/6][v2] audit: implement multicast socket for journald
Date: Wed, 23 Apr 2014 11:52:20 -0400
Message-ID: <5357E1B4.2030705@redhat.com>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
	<cover.1398215388.git.rgb@redhat.com> <26389161.vp9iWSVLPX@x2>
	<1398225475.750.7.camel@localhost> <5357C2D2.5060700@redhat.com>
	<1398264152.2596.25.camel@flatline.rdu.redhat.com>
	<5357DE12.7040905@redhat.com>
	<1398267458.2562.0.camel@flatline.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-audit@redhat.com,
        selinux@tycho.nsa.gov, jamal@mojatatu.com, davem@davemloft.net
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <1398267458.2562.0.camel@flatline.rdu.redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Meaning looking at the journal would be equivalent to looking at
/var/log/audit/audit.log.


On 04/23/2014 11:37 AM, Eric Paris wrote:
> On Wed, 2014-04-23 at 11:36 -0400, Daniel J Walsh wrote:
>> I guess the problem would be that the sysadm_t would be able to look at
>> the journal which would now contain the audit content.
> right.  so include it in the sysadm_secadm bool
>
>> On 04/23/2014 10:42 AM, Eric Paris wrote:
>>> On Wed, 2014-04-23 at 09:40 -0400, Daniel J Walsh wrote:
>>>> Here are the capabilities we currently give to sysadm_t with
>>>> sysadm_secadm    1.0.0    Disabled
>>>>
>>>>    allow sysadm_t sysadm_t : capability { chown dac_override
>>>> dac_read_search fowner fsetid kill setgid setuid setpcap linux_immutable
>>>> net_bind_service net_broadcast net_admin net_raw ipc_lock ipc_owner
>>>> sys_rawio sys_chroot sys_ptrace sys_pacct sys_admin sys_boot sys_nice
>>>> sys_resource sys_time sys_tty_config mknod lease audit_write setfcap } ;
>>>>    allow sysadm_t sysadm_t : capability { setgid setuid sys_chroot }
>>>>
>>>>    allow sysadm_t sysadm_t : capability2 { syslog block_suspend } ;
>>>>
>>>> cap_audit_write might be a problem?
>>> cap_audit_write is fine.
>>>
>>> syslogd_t (aka journal) is going to need the new permission
>>> cap_audit_read.  Also, as steve pointed out, someone may be likely to
>>> want to be able to disable that permission easily.
>>>
>>> -Eric
>>>
>
> _______________________________________________
> Selinux mailing list
> Selinux@tycho.nsa.gov
> To unsubscribe, send email to Selinux-leave@tycho.nsa.gov.
> To get help, send an email containing "help" to Selinux-request@tycho.nsa.gov.
>
>
