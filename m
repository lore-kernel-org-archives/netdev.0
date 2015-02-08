From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH next 4/6] bonding: Allow userspace to set system_priority
Date: Sat, 07 Feb 2015 23:46:24 -0800
Message-ID: <13353.1423381584@famine>
References: <1423270314-9271-1-git-send-email-maheshb@google.com> <20150207033847.GD34197@gospo.home.greyhouse.net> <6873.1423289974@famine> <CAF2d9ji-m6Suw_Rw6dBqs=Ky41h786rCrPh-J7tv7JA+4L84zw@mail.gmail.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55745 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759065AbbBICpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 21:45:53 -0500
In-reply-to: <CAF2d9ji-m6Suw_Rw6dBqs=Ky41h786rCrPh-J7tv7JA+4L84zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <maheshb@google.com> wrote:

>On Fri, Feb 6, 2015 at 10:19 PM, Jay Vosburgh
><jay.vosburgh@canonical.com> wrote:
>> Andy Gospodarek <gospo@cumulusnetworks.com> wrote:
>>
>>>On Fri, Feb 06, 2015 at 04:51:54PM -0800, Mahesh Bandewar wrote:
>>>> This patch allows user to randomize the system-priority in an ad-system.
>>>> The allowed range is 1 - 0xFFFF while default value is 0xFFFF. If user
>>>> does not specify this value, the system defaults to 0xFFFF, which is
>>>> what it was before this patch.
>>>>
>>>> Following example code could set the value -
>>>>     # modprobe bonding mode=4
>>>>     # sys_prio=$(( 1 + RANDOM + RANDOM ))
>>>>     # echo $sys_prio > /sys/class/net/bond0/bonding/ad_actor_system_priority
>>>
>>>If I can convince you to change 'ad_actor_system_macaddr' to something
>>>different can I also convince you to change this to something shorter,
>>>too?  :)
>>>
>>>Maybe 'ad_sys_priority' or something?
>>
>>         The name, verbose as it is, is from the 802.1AX standard, and
>> there's also a "partner_system_priority" (which is not a user-settable
>> thing, it's a field in the LACPDUs).  My suggestion would therefore be
>> "ad_actor_sys_prio" for this one, as I think there's some value in
>> continuity with the names from the standard.
>>
>>         The MAC address one in the standard is just "actor_system";
>> there's a "partner_system" here, too, which is also a field in the
>> LACPDU.  I'm ok with calling that one just "actor_system," as presumably
>> anyone changing it will know what it means.
>>
>Thank you guys for the suggestions. I didn't like those very long
>names either but when there is something that already has name
>similar, I defaulted to being verbose. I will have the name changed to
>-
>
>ad_actor_system_priority            - ad_actor_sys_prio
>ad_actor_system_mac_address - ad_actor_system
>ad_actor_user_port_key             - ad_user_portkey
>
>Is this reasonable enough?

	Perhaps nitpicking, but I'd call it ad_user_port_key.

	I agree that this one should not have "actor" in it, as this
particular value is an invention of bonding and isn't directly part of
the standard.  In bonding, the "user key" (always 0 prior to this
patch), speed, and duplex are used to generate the actor_admin_port_key
and actor_oper_port_key.  Those latter two are part of the standard, but
have no required format.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
