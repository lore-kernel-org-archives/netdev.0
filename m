From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 17:42:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF0BF545FE.0DFC1A2C-ON88256DD6.0008E5F7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Nope, I still get the panic with the change you suggested. We need to
understand this better though we seem to
be on the right track. I will try to get the stack now (couldn't get this
time since I was on the X display, my mouse
still works but not the keyboard).

Thanks,

- KK



|---------+---------------------------->
|         |           Stephen Hemminger|
|         |           <shemminger@osdl.|
|         |           org>             |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           11/05/2003 05:33 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       Krishna Kumar/Beaverton/IBM@IBMUS                                                               |
  |       cc:       davem@redhat.com, krkumar@us.ltcfwd.linux.ibm.com, netdev@oss.sgi.com                           |
  |       Subject:  Re: [PATCH] panic during unregister_netdevice()                                                 |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|




On Wed, 5 Nov 2003 17:20:06 -0800
Krishna Kumar <kumarkr@us.ibm.com> wrote:

>
>
>
>
> So how will this guarantee that the dev is valid after the dev_put() long
> enough to do the
> BUG_ON() and dev->destructor code ? Won't the same panic happen ?
>

Because the code there should be able to depend on having the last
reference.
No other code should be able to find the dev to get a new reference to it,
since it is no longer in the dev_list.  Code that does dev_hold's
without already having a reference is just not playing fair.


> Any idea how the dev gets freed up ? I was still in the old 2.4 kernel
mode
> thinking that
> dev_put does it, but it seems to be done by using the class/object stuff
in
> free_netdev().
>
> Won't a driver doing a unregister followed by a free_netdev still panic
the
> system if we
> reference the dev at a later stage (even with the put at this place) ?
>
> thanks,
>
> - KK
>
