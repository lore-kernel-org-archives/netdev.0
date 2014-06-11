From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Wed, 11 Jun 2014 13:53:23 +0200
Message-ID: <87y4x33bnw.fsf@nemi.mork.no>
References: <ln6m4k$q49$1@ger.gmane.org> <874mzt55kz.fsf@nemi.mork.no>
	<53971171.5070001@flokli.de> <539712BA.5010004@flokli.de>
	<87lht350y0.fsf@nemi.mork.no> <53982AA7.3090508@flokli.de>
	<CAAP7ucKXPt=Ya3+mfVJ8rEjEkKabFrK0Z4Khaw7U6k-vUuU_Eg@mail.gmail.com>
	<53983C1B.5090805@flokli.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	netdev@vger.kernel.org,
	"ModemManager \(development\)"
	<modemmanager-devel@lists.freedesktop.org>
To: Florian Klink <flokli@flokli.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:58039 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763AbaFKLxl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 07:53:41 -0400
In-Reply-To: <53983C1B.5090805@flokli.de> (Florian Klink's message of "Wed, 11
	Jun 2014 13:23:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian Klink <flokli@flokli.de> writes:
> Am 11.06.2014 12:17, schrieb Aleksander Morgado:
>> On Wed, Jun 11, 2014 at 12:08 PM, Florian Klink <flokli@flokli.de> w=
rote:
>>> Sure, I can provide the message dumps. Is it as simple as described=
 in
>>> here (http://www.freedesktop.org/wiki/Software/ModemManager/Debuggi=
ng/),
>>> or do I need to recompile libmbim + ModemManager with some addition=
al (debug)
>>> flags enabled?
>>=20
>>=20
>> It's just like that; once you run MM with --debug you'll also get
>> libmbim debug messages as well, including all transactions going to
>> and from the modem.
>>=20
>
> Nice! There you go, attached the outputs of ModemManager and
> NetworkManager started in debug mode.
>
>
> I wrote all "actions" (start,configure connection,suspend,resumed,
> connectiong again) between 4 "=3D"-signs, so you can easily recognize=
 what
> happened when.
>
> Hope it sheds some light on the problem :-)

Thanks! Yes, I believe it does.  Or.. at least it confirms that
something strange is going on.  This part of the failed connection
attempt after resume look very odd to me:


ModemManager[1861]: <info>  [1402484694.481304] [mm-iface-modem-simple.=
c:469] connection_step(): Simple connect state (4/8): Wait to get fully=
 enabled
ModemManager[1861]: <info>  [1402484694.481349] [mm-iface-modem-simple.=
c:478] connection_step(): Simple connect state (5/8): Register
ModemManager[1861]: <debug> [1402484694.481374] [mm-iface-modem-3gpp.c:=
395] mm_iface_modem_3gpp_register_in_network(): Launching automatic net=
work registration...
ModemManager[1861]: [/dev/cdc-wdm1] Sent message...
<<<<<< RAW:
<<<<<<   length =3D 64
<<<<<<   data   =3D 03:00:00:00:40:00:00:00:17:00:00:00:01:00:00:00:00:=
00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:09:00:00:00:01=
:00:00:00:10:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
ModemManager[1861]: [/dev/cdc-wdm1] Sent message (translated)...
<<<<<< Header:
<<<<<<   length      =3D 64
<<<<<<   type        =3D command (0x00000003)
<<<<<<   transaction =3D 23
<<<<<< Fragment header:
<<<<<<   total   =3D 1
<<<<<<   current =3D 0
<<<<<< Contents:
<<<<<<   service =3D 'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae=
6df)
<<<<<<   cid     =3D 'register-state' (0x00000009)
<<<<<<   type    =3D 'set' (0x00000001)
ModemManager[1861]: [/dev/cdc-wdm1] Received message...
>>>>>> RAW:
>>>>>>   length =3D 116
>>>>>>   data   =3D 07:00:00:80:74:00:00:00:00:00:00:00:01:00:00:00:00:=
00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:09:00:00:00:48=
:00:00:00:00:00:00:00:03:00:00:00:01:00:00:00:1C:00:00:00:01:00:00:00:3=
0:00:00:00:0A:00:00:00:3C:00:00:00:0A:00:00:00:00:00:00:00:00:00:00:00:=
02:00:00:00:32:00:36:00:32:00:30:00:37:00:00:00:46:00:4F:00:4E:00:49:00=
:43:00:00:00
ModemManager[1861]: [/dev/cdc-wdm1] Received message (translated)...
>>>>>> Header:
>>>>>>   length      =3D 116
>>>>>>   type        =3D indicate-status (0x80000007)
>>>>>>   transaction =3D 0
>>>>>> Fragment header:
>>>>>>   total   =3D 1
>>>>>>   current =3D 0
>>>>>> Contents:
>>>>>>   service =3D 'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae=
6df)
>>>>>>   cid     =3D 'register-state' (0x00000009)
ModemManager[1861]: <debug> [1402484694.508028] [mm-broadband-modem-mbi=
m.c:1771] device_notification_cb(): Received notification (service 'bas=
ic-connect', command 'register-state')
ModemManager[1861]: <info>  [1402484694.508077] [mm-iface-modem-3gpp.c:=
1152] update_registration_state(): Modem /org/freedesktop/ModemManager1=
/Modem/0: 3GPP Registration state changed (searching -> registering)
ModemManager[1861]: <info>  [1402484694.508133] [mm-iface-modem.c:894] =
mm_iface_modem_update_access_technologies(): Modem /org/freedesktop/Mod=
emManager1/Modem/0: access technology changed (unknown -> umts, hsdpa, =
hsupa)
ModemManager[1861]: <info>  [1402484694.508187] [mm-iface-modem-locatio=
n.c:293] notify_3gpp_location_update(): Modem /org/freedesktop/ModemMan=
ager1/Modem/0: 3GPP location updated (MCC: '262', MNC: '7', Location ar=
ea code: '0', Cell ID: '0')
ModemManager[1861]: <debug> [1402484694.508343] [mm-broadband-modem.c:3=
476] modem_3gpp_load_subscription_state(): Load subscription state: Mar=
king the SIM as provisioned.
ModemManager[1861]: <info>  [1402484694.508479] [mm-iface-modem-3gpp.c:=
1077] update_registration_reload_current_registration_info_ready(): Mod=
em /org/freedesktop/ModemManager1/Modem/0: 3GPP Registration state chan=
ged (registering -> home)
NetworkManager[1862]: <debug> [1402484701.903039] [nm-netlink-monitor.c=
:164] link_msg_handler(): netlink link message: iface idx 3 flags 0x100=
3
NetworkManager[1862]: <debug> [1402484744.894312] [nm-netlink-monitor.c=
:164] link_msg_handler(): netlink link message: iface idx 3 flags 0x100=
3
ModemManager[1861]: <debug> [1402484747.346282] [mm-iface-modem.c:1080]=
 expire_signal_quality(): Signal quality value not updated in 60s, mark=
ing as not being recent



Here we send a 'register-state' command which the firmware never replie=
s
to, but instead we get an unsolicited 'register-state' indication
showing that the modem is registered in the home network.  But where di=
d
the reply to the command with transaction id 23 go?  That looks like a
firmware issue to me.  Which we probably just have to work around
somehow...

Then we continue with a 'signal-state' indication (which is expected),
followed by ModemManager concluding that the registration state is
changed to 'idle' and failing due to that:

ModemManager[1861]: [/dev/cdc-wdm1] Received message...
>>>>>> RAW:
>>>>>>   length =3D 64
>>>>>>   data   =3D 07:00:00:80:40:00:00:00:00:00:00:00:01:00:00:00:00:=
00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:0B:00:00:00:14=
:00:00:00:12:00:00:00:63:00:00:00:05:00:00:00:02:00:00:00:FF:FF:FF:FF
ModemManager[1861]: [/dev/cdc-wdm1] Received message (translated)...
>>>>>> Header:
>>>>>>   length      =3D 64
>>>>>>   type        =3D indicate-status (0x80000007)
>>>>>>   transaction =3D 0
>>>>>> Fragment header:
>>>>>>   total   =3D 1
>>>>>>   current =3D 0
>>>>>> Contents:
>>>>>>   service =3D 'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae=
6df)
>>>>>>   cid     =3D 'signal-state' (0x0000000b)
ModemManager[1861]: <debug> [1402484754.090164] [mm-broadband-modem-mbi=
m.c:1771] device_notification_cb(): Received notification (service 'bas=
ic-connect', command 'signal-state')
ModemManager[1861]: <debug> [1402484754.090172] [mm-broadband-modem-mbi=
m.c:1524] basic_connect_notification_signal_state(): Signal state indic=
ation: 18 --> 58%
ModemManager[1861]: <info>  [1402484754.090224] [mm-iface-modem.c:1144]=
 update_signal_quality(): Modem /org/freedesktop/ModemManager1/Modem/0:=
 signal quality updated (58)
ModemManager[1861]: <info>  [1402484754.484416] [mm-iface-modem-3gpp.c:=
1167] update_registration_state(): Modem /org/freedesktop/ModemManager1=
/Modem/0: 3GPP Registration state changed (home -> idle)
ModemManager[1861]: <info>  [1402484754.484496] [mm-iface-modem-locatio=
n.c:293] notify_3gpp_location_update(): Modem /org/freedesktop/ModemMan=
ager1/Modem/0: 3GPP location updated (MCC: '0', MNC: '0', Location area=
 code: '0', Cell ID: '0')
ModemManager[1861]: <debug> [1402484754.484540] [mm-bearer.c:261] modem=
_3gpp_registration_state_changed(): Bearer not allowed to connect, not =
registered in 3GPP network
ModemManager[1861]: <info>  [1402484754.484570] [mm-iface-modem.c:894] =
mm_iface_modem_update_access_technologies(): Modem /org/freedesktop/Mod=
emManager1/Modem/0: access technology changed (umts, hsdpa, hsupa -> un=
known)
NetworkManager[1862]: <warn> (cdc-wdm1) failed to connect modem: Networ=
k timeout
NetworkManager[1862]: <info> (cdc-wdm1): device state change: prepare -=
> failed (reason 'gsm-registration-timeout') [40 120 32]
NetworkManager[1862]: <info> NetworkManager state is now DISCONNECTED
NetworkManager[1862]: <debug> [1402484754.485784] [nm-manager.c:4165] p=
olicy_activating_device_changed(): ActivatingConnection now (none)
NetworkManager[1862]: <warn> Activation (cdc-wdm1) failed for connectio=
n 'FONIC Vorgabe'
NetworkManager[1862]: <debug> [1402484754.485885] [nm-device.c:5261] nm=
_device_queue_state(): (cdc-wdm1): queued state change to disconnected =
(id 431)
NetworkManager[1862]: <debug> [1402484754.486259] [nm-device.c:5219] qu=
eued_set_state(): (cdc-wdm1): running queued state change to disconnect=
ed (id 431)
NetworkManager[1862]: <info> (cdc-wdm1): device state change: failed ->=
 disconnected (reason 'none') [120 30 0]
NetworkManager[1862]: <info> (cdc-wdm1): deactivating device (reason 'n=
one') [0]
NetworkManager[1862]: <debug> [1402484754.486360] [nm-firewall-manager.=
c:166] nm_firewall_manager_remove_from_zone(): (cdc-wdm1) firewall zone=
 remove skipped (not running)
NetworkManager[1862]: <debug> [1402484754.486649] [nm-dns-manager.c:995=
] nm_dns_manager_begin_updates(): (update_routing_and_dns): queueing DN=
S updates (1)
NetworkManager[1862]: <debug> [1402484754.486718] [nm-dns-manager.c:101=
3] nm_dns_manager_end_updates(): (nm_dns_manager_end_updates): DNS conf=
iguration did not change
NetworkManager[1862]: <debug> [1402484754.486745] [nm-dns-manager.c:101=
7] nm_dns_manager_end_updates(): (update_routing_and_dns): no DNS chang=
es to commit (0)



But there are no MBIM messages explaining why MM sets the state to
'idle'.  Is this because of the missing reply, Alexander?  Why don't we
just trust the (more current) result from the indication?  We do know
that the modem is registered to the home network here, or?


Bj=C3=B8rn
