From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next V4] tc: flower: Refactor matching flags to be
 more user friendly
Date: Fri, 20 Jan 2017 12:27:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0268D18@AcuExch.aculab.com>
References: <1484835468-46051-1-git-send-email-paulb@mellanox.com>
 <20170119152218.61aa2fc4@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: 'Jiri Benc' <jbenc@redhat.com>, Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:56493 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752164AbdATM1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 07:27:51 -0500
In-Reply-To: <20170119152218.61aa2fc4@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Jiri Benc
> Sent: 19 January 2017 14:22
> On Thu, 19 Jan 2017 16:17:48 +0200, Paul Blakey wrote:
> > +	while (token) {
> > +		if (!strncmp(token, "no", 2)) {
> > +			no = true;
> > +			token = strchr(token, '_') + 1;
> 
> This seems to still assume that "no" is followed by an underscore.
> What about a simple token += 2?

Actually it was rather worse than that and probably shows a
distinct lack of testing.
Consider what happened with "no", "nofubar" and "nofubar_baz",
all ought to be rejected.

Actually using strncmp() is also overkill.
Nothing wrong with:
	if (token[0] == 'n' && token[1] == 'o' && token[2]) {
		no = true;
		token += 2;
		if (token[0] == '_' && token[1])
			token++;
		...

or replace the last 3 lines with:
		token += 2 + (token[2] == '_' & token[3]);

	David
