From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/9] bonding: remove __get_first_port()
Date: Fri, 27 Sep 2013 15:50:12 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7365@saturn3.aculab.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com> <1380291125-5671-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <nikolay@redhat.com>, <bhutchings@solarflare.com>,
	"Jay Vosburgh" <fubar@us.ibm.com>,
	"Andy Gospodarek" <andy@greyhouse.net>
To: "Veaceslav Falico" <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39317 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751185Ab3I0Owl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 10:52:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03294-05 for <netdev@vger.kernel.org>;
 Fri, 27 Sep 2013 15:52:37 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1380291125-5671-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -2104,8 +2091,11 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 
>  	// check if agg_select_timer timer after initialize is timed out
>  	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
> +		slave = bond_first_slave(bond);
> +		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
> +
>  		// select the active aggregator for the bond
> -		if ((port = __get_first_port(bond))) {
> +		if (port) {
>  			if (!port->slave) {
>  				pr_warning("%s: Warning: bond's first port is uninitialized\n",
>  					   bond->dev->name);
> --

Looks like that could be:
		slave = bond_first_slave(bond);
		if (slave) {
			port = SLAVE_AD_INFO(slave).port;
and I assume 'slave == port->slave' so there is no need for the latter check?

	David
