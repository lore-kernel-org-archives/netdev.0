From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 9 Feb 2005 17:19:46 +0300
Message-ID: <20050209141945.GA28864@yakov.inr.ac.ru>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <Pine.LNX.4.62.0502080658310.32526@kaber.coreworks.de> <1107956079.17568.42.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Audit Discussion <linux-audit@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>, netdev@oss.sgi.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Stephen Smalley <sds@epoch.ncsc.mil>
Content-Disposition: inline
In-Reply-To: <1107956079.17568.42.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > Reception of netlink messages in the kernel happens in the context
> > of the sending process, so you can simply call
> > audit_get_loginuid(current->audit_context) in audit_receive_msg().
> 
> Then why does netlink_sendmsg() need to save the effective capability

Yes, when kernel receives a message, it can be processed in context
of another process. This happens with rtnetlink, which queues messages
when someone holds netadmin semaphore and processing of backlog happens
in context of process which holds the semaphore.

Unfortunately, audit uses the same twisted way. Actually, if people
expected synchronous processing, it is better to replace

if (down_trylock(&audit_netlink_sem))
	return;

with plain down(&audit_netlink_sem);

Alexey
