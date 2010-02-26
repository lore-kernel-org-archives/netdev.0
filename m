From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 26 Feb 2010 13:24:53 -0800
Message-ID: <m1bpfbwuze.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B883987.6090408@parallels.com> (Pavel Emelyanov's message of "Sat\, 27 Feb 2010 00\:13\:43 +0300")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@parallels.com> writes:

>> +static struct inode *nsfd_mkinode(void)
>> +{
>> +	struct inode *inode;
>> +	inode = new_inode(nsfd_mnt->mnt_sb);
>> +	if (!inode)
>> +		return ERR_PTR(-ENOMEM);
>> +
>> +	inode->i_fop = &nsfd_file_operations;
>> +
>> +	/*
>> +	 * Mark the inode dirty from the very beginning,
>> +	 * that way it will never be moved to the dirty
>> +	 * list because mark_inode_dirty() will think that
>> +	 * it already _is_ on the dirty list.
>> +	 */
>> +	inode->i_state = I_DIRTY;
>> +	inode->i_mode = S_IRUSR | S_IWUSR;
>> +	inode->i_uid = current_fsuid();
>> +	inode->i_gid = current_fsgid();
>> +	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>> +	return inode;
>> +}
>
> Why not use anon inodes?

Because you can't mount them anywhere.

>> diff --git a/include/linux/nstype.h b/include/linux/nstype.h
>> new file mode 100644
>> index 0000000..3bdf856
>> --- /dev/null
>> +++ b/include/linux/nstype.h
>> @@ -0,0 +1,6 @@
>> +#ifndef _LINUX_NSTYPE_H
>> +#define _LINUX_NSTYPE_H
>> +
>> +#define NSTYPE_NET 0
>> +
>> +#endif /* _LINUX_NSTYPE_H */
>
> Yet another set of per-namespace IDs along with CLONE_NEWXXX ones?
> I currently have a way to create all namespaces we have with one
> syscall. Why don't we have an ability to enter them all with one syscall?

The CLONE_NEWXXX series of bits has been an royal pain to work with,
and it appears to be unnecessary complications for no gain.

Eric

