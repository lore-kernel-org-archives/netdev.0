From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Wed, 11 Jun 2014 17:05:03 +0200
Message-ID: <CAAP7ucJ+3wM9wWYSXOBbfAY3zTt1q3TA1h5MWq=XUUqDPqWf=g@mail.gmail.com>
References: <ln6m4k$q49$1@ger.gmane.org>
	<874mzt55kz.fsf@nemi.mork.no>
	<53971171.5070001@flokli.de>
	<539712BA.5010004@flokli.de>
	<87lht350y0.fsf@nemi.mork.no>
	<53982AA7.3090508@flokli.de>
	<CAAP7ucKXPt=Ya3+mfVJ8rEjEkKabFrK0Z4Khaw7U6k-vUuU_Eg@mail.gmail.com>
	<53983C1B.5090805@flokli.de>
	<87y4x33bnw.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Klink <flokli@flokli.de>, netdev@vger.kernel.org,
	"ModemManager (development)"
	<modemmanager-devel@lists.freedesktop.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:62303 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932194AbaFKPFE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 11:05:04 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so4527152obc.1
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 08:05:04 -0700 (PDT)
In-Reply-To: <87y4x33bnw.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 1:53 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> ModemManager[1861]: <info>  [1402484754.484416] [mm-iface-modem-3gpp.=
c:1167] update_registration_state(): Modem /org/freedesktop/ModemManage=
r1/Modem/0: 3GPP Registration state changed (home -> idle)
> ModemManager[1861]: <info>  [1402484754.484496] [mm-iface-modem-locat=
ion.c:293] notify_3gpp_location_update(): Modem /org/freedesktop/ModemM=
anager1/Modem/0: 3GPP location updated (MCC: '0', MNC: '0', Location ar=
ea code: '0', Cell ID: '0')
> ModemManager[1861]: <debug> [1402484754.484540] [mm-bearer.c:261] mod=
em_3gpp_registration_state_changed(): Bearer not allowed to connect, no=
t registered in 3GPP network
> ModemManager[1861]: <info>  [1402484754.484570] [mm-iface-modem.c:894=
] mm_iface_modem_update_access_technologies(): Modem /org/freedesktop/M=
odemManager1/Modem/0: access technology changed (umts, hsdpa, hsupa -> =
unknown)
> NetworkManager[1862]: <warn> (cdc-wdm1) failed to connect modem: Netw=
ork timeout
> NetworkManager[1862]: <info> (cdc-wdm1): device state change: prepare=
 -> failed (reason 'gsm-registration-timeout') [40 120 32]
> NetworkManager[1862]: <info> NetworkManager state is now DISCONNECTED
> NetworkManager[1862]: <debug> [1402484754.485784] [nm-manager.c:4165]=
 policy_activating_device_changed(): ActivatingConnection now (none)
> NetworkManager[1862]: <warn> Activation (cdc-wdm1) failed for connect=
ion 'FONIC Vorgabe'
> NetworkManager[1862]: <debug> [1402484754.485885] [nm-device.c:5261] =
nm_device_queue_state(): (cdc-wdm1): queued state change to disconnecte=
d (id 431)
> NetworkManager[1862]: <debug> [1402484754.486259] [nm-device.c:5219] =
queued_set_state(): (cdc-wdm1): running queued state change to disconne=
cted (id 431)
> NetworkManager[1862]: <info> (cdc-wdm1): device state change: failed =
-> disconnected (reason 'none') [120 30 0]
> NetworkManager[1862]: <info> (cdc-wdm1): deactivating device (reason =
'none') [0]
> NetworkManager[1862]: <debug> [1402484754.486360] [nm-firewall-manage=
r.c:166] nm_firewall_manager_remove_from_zone(): (cdc-wdm1) firewall zo=
ne remove skipped (not running)
> NetworkManager[1862]: <debug> [1402484754.486649] [nm-dns-manager.c:9=
95] nm_dns_manager_begin_updates(): (update_routing_and_dns): queueing =
DNS updates (1)
> NetworkManager[1862]: <debug> [1402484754.486718] [nm-dns-manager.c:1=
013] nm_dns_manager_end_updates(): (nm_dns_manager_end_updates): DNS co=
nfiguration did not change
> NetworkManager[1862]: <debug> [1402484754.486745] [nm-dns-manager.c:1=
017] nm_dns_manager_end_updates(): (update_routing_and_dns): no DNS cha=
nges to commit (0)
>
>
>
> But there are no MBIM messages explaining why MM sets the state to
> 'idle'.  Is this because of the missing reply, Alexander?  Why don't =
we
> just trust the (more current) result from the indication?  We do know
> that the modem is registered to the home network here, or?

Gah....

Yeah, that's the thing:

static void
register_in_network_context_failed (RegisterInNetworkContext *ctx,
                                    GError *error)
{
    mm_iface_modem_3gpp_update_cs_registration_state (ctx->self,
MM_MODEM_3GPP_REGISTRATION_STATE_IDLE);
    mm_iface_modem_3gpp_update_ps_registration_state (ctx->self,
MM_MODEM_3GPP_REGISTRATION_STATE_IDLE);
    mm_iface_modem_3gpp_update_eps_registration_state (ctx->self,
MM_MODEM_3GPP_REGISTRATION_STATE_IDLE);
    mm_iface_modem_3gpp_update_access_technologies (ctx->self,
MM_MODEM_ACCESS_TECHNOLOGY_UNKNOWN);
    mm_iface_modem_3gpp_update_location (ctx->self, 0, 0);

    g_simple_async_result_take_error (ctx->result, error);
}

Well, I guess we should try to detect the indication and if so, use it
as 'reply' to the request we sent. Luckily both the indication and the
response will have the same info:

    imbim_message_register_state_notification_parse (
            notification,
            NULL, /* nw_error */
            &register_state,
            NULL, /* register_mode */
            &available_data_classes,
            NULL, /* current_cellular_class */
            &provider_id,
            &provider_name,
            NULL, /* roaming_text */
            NULL, /* registration_flag */
            NULL)

        mbim_message_register_state_response_parse (
            response,
            NULL, /* nw_error */
            &register_state,
            NULL, /* register_mode */
            &available_data_classes,
            NULL, /* current_cellular_class */
            &provider_id,
            &provider_name,
            NULL, /* roaming_text */
            NULL, /* registration_flag */
            NULL)

Ugly hack, but I guess there's no other way to handle this firmware iss=
ue?

Another option would be to avoid moving the state to IDLE when
registration check fails, but that's pretty generic in every flow for
every modem, not sure if we should touch that.

--=20
Aleksander
https://aleksander.es
