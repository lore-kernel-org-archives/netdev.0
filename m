From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: fix vport-netdev
	unregister
Date: Thu, 10 Oct 2013 21:48:44 -0700
Message-ID: <CAMEtUuzf5UbZ_87DU+vSMbKzxLQgmuEfrf3NXQSz7vSF8LQTzw@mail.gmail.com>
References: <1381288051-3607-1-git-send-email-ast@plumgrid.com>
	<CALnjE+p3MC7D9oYZ4VhH=fdOWSYcV6h9twnaZBocYnRdAEcpBg@mail.gmail.com>
	<CAMEtUuzVP0LQ_L2CrpoJgehP_bXwYhicW_HM2m-YOY6SN7RDxQ@mail.gmail.com>
	<CALnjE+pLon2DGc=MfrG7Tsu=p_uF9chK=TREJwK_TM2Um89p6Q@mail.gmail.com>
	<CAMEtUuzP1b_VNqP1texkrQ7kvCRxEukUoRz=Dj-pMX9gsO9AWw@mail.gmail.com>
	<CALnjE+oXJQoPG4io2JOn1zBbf7XtPKaBE+vHPNKXm2TBygvB5Q@mail.gmail.com>
	<CAMEtUuxH24G6pQtSFznrK7w5mdP3za4uQfKKEEaEngW4SJajbA@mail.gmail.com>
	<CALnjE+rgasL+XShQN20b9PkFNGq38+UoXX4uLogrZ2igAwfDew@mail.gmail.com>
	<CAMEtUuyEw81g8+68HUMpR1RERAA9rjL=WHRE58se83cdur67eg@mail.gmail.com>
	<CAEP_g=_meOUPrYc7S8rM4NwT_7qG1JZrHJkOg6CmbjDc-rFjAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=_meOUPrYc7S8rM4NwT_7qG1JZrHJkOg6CmbjDc-rFjAQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2013 at 8:56 PM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Oct 10, 2013 at 5:47 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> On Thu, Oct 10, 2013 at 3:38 PM, Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>>> On Thu, Oct 10, 2013 at 1:48 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>> On Thu, Oct 10, 2013 at 11:21 AM, Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>>>>> On Wed, Oct 9, 2013 at 11:26 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>>>> On Wed, Oct 9, 2013 at 11:07 PM, Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>>>>>>> On Wed, Oct 9, 2013 at 9:11 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>>>>>> On Wed, Oct 9, 2013 at 8:02 PM, Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>>>>>>>>> On Tue, Oct 8, 2013 at 8:07 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>>>>>>>> The combination of two commits
>>>>>>>>>>
>>>>>>>>>> commit 8e4e1713e4
>>>>>>>>>> ("openvswitch: Simplify datapath locking.")
>>>>>>>>>>
>>>>>>>>>> and
>>>>>>>>>>
>>>>>>>>>> commit 2537b4dd0a
>>>>>>>>>> ("openvswitch:: link upper device for port devices")
>>>>>>>>>>
>>>>>>>>>> introduced a bug where upper_dev wasn't unlinked upon
>>>>>>>>>> netdev_unregister notification
>>>>>>>>>>
>>>>>>>>>> The following steps:
>>>>>>>>>>
>>>>>>>>>>   modprobe openvswitch
>>>>>>>>>>   ovs-dpctl add-dp test
>>>>>>>>>>   ip tuntap add dev tap1 mode tap
>>>>>>>>>>   ovs-dpctl add-if test tap1
>>>>>>>>>>   ip tuntap del dev tap1 mode tap
>>>>>>>>>>
>>>>>>>>>> are causing multiple warnings:
>>>>>>>>>> diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
>>>>>>>>>> index c323567..e9380bd 100644
>>>>>>>>>> --- a/net/openvswitch/dp_notify.c
>>>>>>>>>> +++ b/net/openvswitch/dp_notify.c
>>>>>>>>>> @@ -88,6 +88,11 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
>>>>>>>>>>                 return NOTIFY_DONE;
>>>>>>>>>>
>>>>>>>>>>         if (event == NETDEV_UNREGISTER) {
>>>>>>>>>> +               /* rx_handler_unregister and upper_dev_unlink immediately */
>>>>>>>>>> +               if (dev->reg_state == NETREG_UNREGISTERING)
>>>>>>>>>> +                       ovs_netdev_unlink_dev(vport);
>>>>>>>>>> +
>>>>>>>>>
>>>>>>>>> Rather than doing vport destroy here, we can just unlink upper device
>>>>>>>>> and let workq do rest of work.
>>>>>>>>
>>>>>>>> isn't it what it's doing?
>>>>>>>
>>>>>>> I meant just call netdev_upper_dev_unlink() here in event handler and
>>>>>>> rest of vport destroy can be done in workq.
>>>>>>
>>>>>> netdev_upper_dev_unlink() without netdev_rx_handler_unregister() ?!
>>>>>> that's dangerous.
>>>>> why is it dangerous? ovs already had ref to net-device.
>>>>
>>>> comment from dev.c:
>>>>                 /* Notify protocols, that we are about to destroy
>>>>                    this device. They should clean all the things.
>>>>                 */
>>>>                 call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>>>>
>>>> so here you're suggesting to just netdev_upper_dev_unlink() to silence
>>>> the warning,
>>>> but then do dev_set_promisc(-1) in workqueue?
>>>>
>>> promiscuity setting is different issue. If you want to have discussion
>>> then you can post separate patch for same. Lets fix the warning here.
>>>
>>>> well, as a minimum audit of promiscuity will be wrong.
>>>> ndo_change_rx_flags will be called after ndo_uninit,
>>>> all sorts of other cleanups are done.
>>>
>>> change_rx_flags() checks for UP flag for given device.
>>>
>>>> I cannot track all possible scenarios, but it seems much safer to
>>>> cleanup everything possible
>>>> as soon as ovs received NETDEV_UNREGISTER event.
>>>>
>>>> May be all these risks are worth taking, then please explain what is
>>>> the problem with the proposed patch?
>>>>
>>> Problem is that this is causing layering issues in OVS. dp_notify is
>>> suppose to work at dp layer. your patch directly calls vport-netdev
>>> implementation function from dp_notify.
>>> I could not think of a simple approach that will do this in completely
>>> clean manner. Therefore I am trying to minimize layering issues. So
>>> just calling netdev_upper_dev_unlink() looks better than doing
>>> anything extra.
>>
>> dp_notify is per net, not per dp.
>> notifier can only be called for net_device and the first thing it does:
>>         if (!ovs_is_internal_dev(dev))
>>                 vport = ovs_netdev_get_vport(dev);
>> where ovs_netdev_get_vport() is defined in vport-netdev.c
>>
>> once it gets into workq, it checks for:
>>        if (vport->ops->type != OVS_VPORT_TYPE_NETDEV)
>>              continue;
>> and
>>         netdev_vport = netdev_vport_priv(vport);
>> where netdev_vport_priv() is defined in netdev-vport.h
>>
>> only then it proceeds with generic ovs_dp_detach_port().
>>
>> Is that the layering you talking about?
>>
>> So to minimize layering issues you want to call 'upper_dev_link' from
>> netdev_create() in vport-netdev.c
>> and 'upper_dev_unlink' directly from dp_device_event() in dp_notify.c?
>>
>> That will look better than calling ovs_netdev_unlink_dev() ?
>
> At a minimum, this function name is misleading because it does a bunch
> of other things beyond unlink the device.

sure. Please propose a different name.

> At this point, it basically seems like six of one, half dozen of the
> other. I don't think that either solution is ideal but it doesn't
> really matter all that much.
>
> However, the check dev->reg_state in netdev_destroy() looks racy to
> me, as it could already be in NETREG_UNREGISTERED even if we already
> processed this device.

you mean that netdev_destroy() will see reg_state == netreg_unregistered,
while dp_device_event() didn't see reg_state == netreg_unregistering yet?
or dp_device_event() saw it, proceeded to do unlink and
netdev_destroy() ran in parallel?
well, that's why reg_state == netreg_unregistering check in netdev_destroy()
is done with rtnl_lock() held.
reg_state cannot go into netreg_unregistered state skipping
netreg_unregistering and notifier.
therefore I don't think it's racy.

In ovs_dp_notify_wq() you're checking for both unregistering and
unregistered and that makes
sense, since workq can run after unregistering notifier called and
netdev_run_todo()
already changed the state to unregistered.
But here it's not the case.
