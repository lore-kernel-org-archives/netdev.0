From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 10:10:23 -0800 (PST)
Message-ID: <20050210181023.92819.qmail@web50202.mail.yahoo.com>
References: <20050210175221.GA13458@w-m-p.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, davem@davemloft.net, netdev@oss.sgi.com
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <20050210175221.GA13458@w-m-p.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- Klaus Weidner <klaus@atsec.com> wrote:

> Both CAPP and LSPP assume trustworthy
> administrators, and those
> protection profiles don't really support the concept
> of fine grained
> capabilities for not-quite-administrator tasks.

I don't know where you get that idea, as it is
inconsistent with the evaluations I have done.
A fine grained capability model that is used
will always make an evaluation easier. A process
that runs with partial privilege requires much
less supporting evidence for evaluation than
one that has superuser privilege. The Criteria
may not require fine grained privilege, but
that does not mean it doesn't help.

> The CAPP and LSPP audit requirements include that
> audit records contain
> the subject identity, this corresponds to the login
> UID.

The subject identity is the name of the subject,
that is the process ID. The user associated with
the session is the login UID. The user is not the
subject.

> The point of the
> user messages is to support proper auditing of
> actions that aren't
> directly related to system calls, such as
> authenticating users, modifying
> security databases, and similar things. This is
> always done by trusted
> processes, so the technical method used to get the
> login UID into the
> audit record for user messages doesn't matter as
> long as it can't be
> falsified by non-administrators.

This is correct as far as it goes. One of the
requirements is to correctly audit attempts made
by unprivileged users to write to the audit trail.
This is one reason you need the login UID of the
process attempting to write to the audit trail.

> A CAPP/LSPP compliant implementation could for
> example completely bypass
> the kernel and append user messages from trusted
> processes directly to
> the audit log file - I'm not saying that would be a
> good idea, but it
> could be compliant.

It is actually a very good idea to maintain
modifications to system security databases outside
the audit trail proper. In the Orange Book days
the NSA went so far as to declare a that a
reasonable procedure for keeping them under
revision control would be sufficient to meet the
audit requirements.

Another mechanism that would work well is to
send the user space records directly to the
audit daemon using a protected socket.


=====
Casey Schaufler
casey@schaufler-ca.com


	
		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - You care about security. So do we. 
http://promotions.yahoo.com/new_mail
