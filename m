From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6 2/6] be2net: fix to not drop unfiltered vlan pkts
Date: Mon, 21 Mar 2011 19:21:39 -0700
Message-ID: <AANLkTin-kzwXAodLibFAGNcurPRFBUCHgQR8P6rxiJGh@mail.gmail.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
 <e340379d-68e1-42af-b7b7-94e07e729884@exht1.ad.emulex.com>
 <AANLkTimNHmvFznX-XHmhdVmkRBBjrkEa1OyAB=gSCciu@mail.gmail.com> <3367B80B08154D42A3B2BC708B5D41F63CC492C950@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Sathya.Perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:35698 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762Ab1CVCWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 22:22:00 -0400
Received: by qyk7 with SMTP id 7so3039532qyk.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 19:21:59 -0700 (PDT)
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F63CC492C950@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 20, 2011 at 10:41 PM,  <Sathya.Perla@emulex.com> wrote:
> Hi, can you pls clarify what you mean by the "new vlan model" below...

The interface that drivers use to pass vlan information to the
networking core has changed starting in 2.6.37, although the old
methods still exist for compatibility until all drivers have been
switched over.  The idea is that drivers should no longer need any
knowledge of the vlan group and should instead simply pass along
whatever tagging information was received.  With this patch you are
implicitly relying on the changes because you are giving a NULL vlan
group in some situations, which now works because the compatibility
functions ignore it.

An example of a driver conversion is in 7a8fc77b3744e26ce1249d9ccb23e356d6010679
