From: "m m" <olsajiri@gmail.com>
Subject: Re: netlink - notify when the socket gets closed
Date: Sat, 6 Dec 2008 19:10:52 +0100
Message-ID: <35476bd20812061010g145b6c19r282ae32a4ebfabb1@mail.gmail.com>
References: <35476bd20812050017y70c3c729v450cdc3d0c1188de@mail.gmail.com>
	 <20081205195624.95ea1866.akpm@linux-foundation.org>
	 <493A92FD.3060302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <493A92FD.3060302@trash.net>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 6, 2008 at 3:58 PM, Patrick McHardy <kaber@trash.net> wrote:
> Andrew Morton wrote:
>>
>> (cc netdev@vger.kernel.org)
>>
>> On Fri, 5 Dec 2008 09:17:51 +0100 "m m" <olsajiri@gmail.com> wrote:
>>>
>>> I'm using netlink in my module. Based on the communication,
>>> this module dynamically creates some internal structure, which
>>> needs to be destroyed when the user level socket is closed (or
>>> the application dies).
>>>
>>> I found I could use the netlink_register_notifier function to register
>>> NETLINK_URELEASE callback during the netlink_release function.
>>> But since my module uses the multicast netlink socket communication,
>>> it wont be called:
>>>
>>> [...]
>>> Whats the reason this callback is not called for multicast sockets?
>>>
>>> To workaround it I created simple misc device which the user application
>>> opens before creating the netlink socket. This way I get some callbacks
>>> inside the module when the application dies, at least.. pretty ugly :)
>>>
>>> Is there a netlink mechanism to be notified when the netlink socket is
>>> closed on the user level side? (when using multicast communication)
>>>
>>> Or is there any other design I could use, since I think I'm not alone in
>>> using internal module data which needs to be removed once the application
>>> dies.
>
>
> That doesn't make sense. When you use multicast, multiple applications
> can be listening to the messages. If you really need state for a single
> listener and exchange messages in both directions, it sounds like you
> should use unicast.
>
>

My user app register in kernel for a data. When there is a first
application request,
kernel module creates an internal record and ask DATA subsystem for a data,
which are then passed to the user application.

The data are then delivered to the application as they are comming from
the DATA subsystem.

When there's another application requesting the same data type, kernel module
just increase reference count in the internal record, and multicast delivers
data to the other app.

Now when one of those applications end, kernel module just decrease
the reference count in the internal record.

When the other application ends, kernel module needs to release the internal
record and ask the DATA subsystem to stop delivering data.

Hope this make sense... I could do some ascii art next time if needed :)

thanks,
jirka
