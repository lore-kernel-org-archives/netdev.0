From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.45
Date: Sat, 02 Nov 2002 03:23:53 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC38B99.6080703@pobox.com>
References: <OFCFEE31E7.E8F27031-ON88256C65.00068E7B@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, ajtuomin@tml.hut.fi,
   kkumar@beaverton.ibm.com.sgi.com, kuznet@ms2.inr.ac.ru,
   linux-kernel@vger.kernel.org, lpetande@tml.hut.fi, netdev@oss.sgi.com,
   Venkata Jagana <jagana@us.ibm.com>, yoshfuji@wide.ad.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:

>Hi Dave,
>
>  
>
>>None of the things you've listed make it desirable to put the home
>>agent registration into the kernel.  All of the operations you
>>describe could be invoked by the userland home agent daemon using very
>>minimal glue logic in the kernel (invoked, for example, via netlink
>>messages).
>>    
>>
>
>I had a couple of comments about putting the registration part in
>userspace.
>When the HA gets a registration request, it needs to perform the following
>actions :
>        1. perform DAD
>        2. get the list of prefixes supported on the home link of the MN.
>        3. create a tunnel between the HA and the MN
>        4. join the solicited node multicast group of the MN's home
>address.
>        5. add the MN's home address to the list of proxy neigh cache entry
>for the HA.
>        6. Send NA on behalf of the MN
>        7. add the new location of the MN in the binding cache.
>        8. and finally send the Binding Registration Success/Failure
>message.
>
>In the above list, the only activities which can be done in userspace are
>#7 and #8 (that I am aware of). The rest of the items can only be done in
>the
>kernel, atleast we need to move the support to kernel. If the HA
>registration
>is completely moved to userspace, it would still need these facilities (#1
>to #6) in the kernel to perform the actions for registration. So even with
>netlink
>we still need the infrastructure in the kernel.
>  
>

Heck no -- the list you sent only further enforces the notion that most 
of this can be in userspace.

Sure, some of the facilities you list are completely in the kernel -- 
but it is best IMO to control them from userspace.  That allows for 
flexibility when it comes to policy decisions being made (if any) as 
well as increased cleanliness of kernel code.

    Jeff
