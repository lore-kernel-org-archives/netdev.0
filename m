From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 09 Feb 2005 13:53:44 -0500
Message-ID: <1107975224.17568.119.camel@moss-spartans.epoch.ncsc.mil>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <Pine.LNX.4.62.0502080658310.32526@kaber.coreworks.de>
	 <1107956079.17568.42.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209141945.GA28864@yakov.inr.ac.ru>
	 <20050209164929.GA30007@yakov.inr.ac.ru>  <420A5BE1.4000003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Linux Audit Discussion <linux-audit@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>, netdev@oss.sgi.com,
        davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <420A5BE1.4000003@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 13:52, Patrick McHardy wrote:
> Could you explain how this can happen ? From what I can see whenever data
> is queued to the receive queue the input function is called immediately
> through sk->sk_data_ready() -> netlink_data_ready() -> nlk->data_ready()
> and processes all queued packets, except in the case you pointed out,
> when audit_netlink_sem is already taken.

More packets may be queued by another sender while audit_receive() is
still processing the original one, so it will process them too.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
