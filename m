From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 15:39:28 -0700
Message-ID: <24691.1498084768@famine>
References: <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com> <20170621.173655.1945994342723484710.davem@davemloft.net> <CALRmy5tn6cgWF5LP5i7w+UTwP1UJCyQoC7Mx7=RvETBUVD-yuw@mail.gmail.com> <20170621.175651.854625612625047729.davem@davemloft.net> <125b4ae9-2cb7-3532-5391-24404cf6eaec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, vfalico@gmail.com,
        andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com
To: Michael J Dilmore <michael.j.dilmore@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <125b4ae9-2cb7-3532-5391-24404cf6eaec@gmail.com>
Content-ID: <24690.1498084768.1@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael J Dilmore <michael.j.dilmore@gmail.com> wrote:

>On 21/06/17 22:56, David Miller wrote:
>
>> From: Michael D <michael.j.dilmore@gmail.com>
>> Date: Wed, 21 Jun 2017 22:41:07 +0100
>>
>>> I don't think you can stop it being dereferenced... you just need to
>>> prevent an attacker from exploiting the null pointer dereference
>>> vulnerability right? And this is done by returning the function right
>>> away?
>> What's all of this about an "attacker"?
>>
>> If there is a bug, we dererence a NULL pointer, and we should
>> fix that bug.
>>
>> The BUG_ON() helps us see where the problem is while at the
>> same time stopping the kernel before the NULL deref happens.
>Ok this is starting to make sense now - went a bit off track but think my
>general thinking is ok - i.e. if we return the function with an error code
>before the dereference then this basically does the same thing as BUG_ON
>but without crashing the kernel.
>
>Something like:
>
>if (WARN_ON(!new_active_slave) {
>    netdev_dbg("Can't add new active slave - pointer null");
>    return ERROR_CODE
>}

	In general, yes, but in this case, the condition should be
impossible to hit, so BUG_ON seems appropriate.

	If bond_slave_get_rtnl/rcu() returns NULL for an actual bonding
slave, other code paths (bond_fill_slave_info, bond_handle_frame) will
likely crash before getting to this one.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
