From: Daniel J Walsh <dwalsh@redhat.com>
Subject: Re: [PATCH 0/6][v2] audit: implement multicast socket for journald
Date: Wed, 23 Apr 2014 09:40:34 -0400
Message-ID: <5357C2D2.5060700@redhat.com>
References: <20140422.161904.1187535812839850973.davem@davemloft.net> <cover.1398215388.git.rgb@redhat.com> <26389161.vp9iWSVLPX@x2> <1398225475.750.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov, jamal@mojatatu.com, davem@davemloft.net
To: Eric Paris <eparis@redhat.com>, Steve Grubb <sgrubb@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1398225475.750.7.camel@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are the capabilities we currently give to sysadm_t with
sysadm_secadm    1.0.0    Disabled

   allow sysadm_t sysadm_t : capability { chown dac_override
dac_read_search fowner fsetid kill setgid setuid setpcap linux_immutable
net_bind_service net_broadcast net_admin net_raw ipc_lock ipc_owner
sys_rawio sys_chroot sys_ptrace sys_pacct sys_admin sys_boot sys_nice
sys_resource sys_time sys_tty_config mknod lease audit_write setfcap } ;
   allow sysadm_t sysadm_t : capability { setgid setuid sys_chroot }

   allow sysadm_t sysadm_t : capability2 { syslog block_suspend } ;

cap_audit_write might be a problem?

On 04/22/2014 11:57 PM, Eric Paris wrote:
> On Tue, 2014-04-22 at 22:25 -0400, Steve Grubb wrote:
>> On Tuesday, April 22, 2014 09:31:52 PM Richard Guy Briggs wrote:
>>> This is a patch set Eric Paris and I have been working on to add a
>>> restricted capability read-only netlink multicast socket to kernel audit to
>>> enable userspace clients such as systemd/journald to receive audit logs, in
>>> addition to the bidirectional auditd userspace client.
>> Do have the ability to separate of secadm_r and sysadm_r? By allowing this, we 
>> will leak to a sysadmin that he is being audited by the security officer. In a 
>> lot of cases, they are one in the same person. But for others, they are not. I 
>> have a feeling this will cause problems for MLS systems.
> Why?  This requires CAP_AUDIT_READ.  Just don't give CAP_AUDIT_READ to
> places you don't want to have read permission.  Exactly the same as you
> don't give CAP_AUDIT_CONTROL to sysadm_r.  (If we are giving
> CAP_AUDIT_CONTROL to sysadm_r and you think that any file protections
> on /var/log/audit/audit.log are adequate we are fooling ourselves!)
>
>> Also, shouldn't we have an audit event for every attempt to connect to this 
>> socket? We really need to know where this information is getting leaked to.
> We certainly can.  What would you like to see in that event?
>
> -Eric
>
> _______________________________________________
> Selinux mailing list
> Selinux@tycho.nsa.gov
> To unsubscribe, send email to Selinux-leave@tycho.nsa.gov.
> To get help, send an email containing "help" to Selinux-request@tycho.nsa.gov.
>
>

