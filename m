From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 09 Feb 2005 15:10:08 +0100
Message-ID: <420A19C0.4070402@trash.net>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>	 <Pine.LNX.4.62.0502080658310.32526@kaber.coreworks.de> <1107956079.17568.42.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Audit Discussion <linux-audit@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>, netdev@oss.sgi.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Stephen Smalley <sds@epoch.ncsc.mil>
In-Reply-To: <1107956079.17568.42.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Smalley wrote:

>On Tue, 2005-02-08 at 01:04, Patrick McHardy wrote:
>  
>
>>Reception of netlink messages in the kernel happens in the context
>>of the sending process, so you can simply call
>>audit_get_loginuid(current->audit_context) in audit_receive_msg().
>>    
>>
>
>Then why does netlink_sendmsg() need to save the effective capability
>set of the sender in the control buffer (via security_netlink_send) for
>later checking by other receive functions in the kernel (via
>security_netlink_recv)?
>
It looks like it doesn't need to, I guess it was copied from 
netlink_sendmsg.
netlink transmission to userspace is asynchronous, some values need to be
saved, but userspace->kernel transmission is synchronous.

>What prevents audit_receive() or other similar
>receive functions in the kernel from processing messages sent by
>multiple senders?
>
Multiple messages from multiple senders are handled by multiple calls to
the input function. Check netlink_kernel_create() and netlink_data_ready().

Regards
Patrick
