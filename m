From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 09 Feb 2005 19:52:17 +0100
Message-ID: <420A5BE1.4000003@trash.net>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <Pine.LNX.4.62.0502080658310.32526@kaber.coreworks.de> <1107956079.17568.42.camel@moss-spartans.epoch.ncsc.mil> <20050209141945.GA28864@yakov.inr.ac.ru> <20050209164929.GA30007@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@epoch.ncsc.mil>,
        Linux Audit Discussion <linux-audit@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>, netdev@oss.sgi.com,
        davem@davemloft.net
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050209164929.GA30007@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:

>Hello!
>
>  
>
>>if (down_trylock(&audit_netlink_sem))
>>	return;
>>
>>with plain down(&audit_netlink_sem);
>>
>
>I am sorry, this is wrong. Dequeue may happen in another process context
>in any case.
>
Could you explain how this can happen ? From what I can see whenever data
is queued to the receive queue the input function is called immediately
through sk->sk_data_ready() -> netlink_data_ready() -> nlk->data_ready()
and processes all queued packets, except in the case you pointed out,
when audit_netlink_sem is already taken.

Regards
Patrick
