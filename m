From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with no
 group
Date: Wed, 19 Mar 2014 08:40:29 -0600
Message-ID: <OF1B9D1A33.8FF4FDD8-ON87257CA0.00509C57-87257CA0.00509C61@us.ibm.com>
References: <CAF1J0HPtQqpaqZ82yPoKFSYpP42HfOGu_X7uz3_61X2b+bYAjQ@mail.gmail.com>,
	<1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>	<OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
	<CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>	<OF55200AFE.3F917127-ON87257CA0.004DA877-87257CA0.004DA87C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43653 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932861AbaCSOkc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 10:40:32 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 19 Mar 2014 08:40:32 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6463219D8036
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:40:27 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2JEdve857737378
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 15:39:57 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2JEeTI4002460
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:40:30 -0600
In-Reply-To: <CAF1J0HPtQqpaqZ82yPoKFSYpP42HfOGu_X7uz3_61X2b+bYAjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Mike Rapoport <mike.rapoport@ravellosystems.com> wrote: -----

>I'm not really familiar with v4 and v6 interoperability, but the
>vxlan_socket_create will create v6 socket only if IPv6 is explicitly
>requested.
>Would it be possible to receive IPv6-encapsulated packets from IPv4
>socket?

=A0 =A0 Yes, if it's bound to INADDR_ANY or "::", which would be the ca=
se
when "vxlan_dev->saddr" aka "ip ... local XXXX" =A0is not specified.

=A0 =A0 And it's a good thing, if mixing protocols is what you want, bu=
t I
think we need to make sure the admin can choose whether it's v4, v6
or both.

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+-DLS
