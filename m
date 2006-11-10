From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 14:49:54 -0800
Message-ID: <45550212.5060207@oracle.com>
References: <45541757.90800@hp.com> <20061110102318.7b344d30.randy.dunlap@oracle.com> <20061110221219.GM8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:14689 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1424454AbWKJWuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:50:24 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061110221219.GM8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Randy Dunlap <randy.dunlap@oracle.com> 2006-11-10 10:23
>> On Fri, 10 Nov 2006 01:08:23 -0500 Paul Moore wrote:
>>
>>> An Introduction To Using Generic Netlink
>>> ===============================================================================
>>> 3.1.2. The genl_family Structure
>>>
>>> Generic Netlink services are defined by the genl_family structure, which is
>>> shown below:
>>>
>>>   struct genl_family
>>>   {
>>>         unsigned int            id;
>>>         unsigned int            hdrsize;
>>>         char                    name[GENL_NAMSIZ];
>>>         unsigned int            version;
>>>         unsigned int            maxattr;
>>>         struct nlattr **        attrbuf;
>>>         struct list_head        ops_list;
>>>         struct list_head        family_list;
>>>   };
>> Any alignment/packing concerns here?  or that is already
>> handled, just not presented here?
> 
> I thought I chose GENL_NAMESIZ wisely but to be sure I checked
> with Mr. Alignment himself, Arnaldo:

Hm, looks OK to me.  Am I missing something?

> struct genl_family {
>         unsigned int               id;                   /* 0(0)     4 */
>         unsigned int               hdrsize;              /* 4(0)     4 */
>         char                       name[16];             /* 8(0)    16 */
>         unsigned int               version;              /* 24(0)     4 */
>         unsigned int               maxattr;              /* 28(0)     4 */
>         /* ---------- cacheline 1 boundary ---------- */
>         struct nlattr * *          attrbuf;              /* 32(0)     4 */
>         struct list_head           ops_list;             /* 36(0)     8 */
>         struct list_head           family_list;          /* 44(0)     8 */
> }; /* size: 52 */

How about field size issues?  Usually for int's etc. that are in
userspace interfaces, we use __u32 etc.

-- 
~Randy
