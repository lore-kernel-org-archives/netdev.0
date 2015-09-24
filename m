From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Thu, 24 Sep 2015 19:43:46 +0200
Message-ID: <56043652.4050603@gmx.net>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
 <20150923162650.148fe95b@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:63353 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754904AbbIXRoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 13:44:20 -0400
In-Reply-To: <20150923162650.148fe95b@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA384

On 09/24/2015 01:26 AM, Stephen Hemminger wrote:
> Having JSON output is going to be a real plus for programatic
> parsing. My understanding of best practice with JSON is that it is
> best to output values in best machine readable form, the format is
> not really meant for humans to directly read.
> 
> Therefore I don't like the code that reformats numbers as hex. If
> the values are better displayed in hex, then it is up to the
> program parsing and presenting that to the user to do that. The
> JSON should just put out numeric values as numeric.
> 
>> +/* hex conversion helper */ +static void
>> jsonw_hex_as_str_outp(json_writer_t *self, uint64_t num) +{ +
>> char tmp[17]; + +	sprintf(tmp, "%"PRIx64, num); +
>> jsonw_string(self, tmp); +} + +static void
>> jsonw_hex_field_outp(json_writer_t *self, const char *prop,
>> uint64_t num) +{ +	jsonw_name(self, prop); +
>> jsonw_hex_as_str_outp(self, num); +} +

I acknowledge that.

> Other than that, my only other discomfort is that this patch set 
> makes the code grow so much larger and it becomes more complex for
> future developers.

Really? Somehow I disagree: I mean most of the code has been copied
over to semantically related modules. So not too much new code has
been added. Modularization in essence should help to get up with
complexity as I see things.

> Maybe it is time to rewrite it in a better language ;-)

I did not get that. Do you mean iproute2?



-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCQAGBQJWBDZSAAoJEOAWT1uK3zQ7lz4H/33aiWxf+Xzk9jjuEToyMMUL
qjhzMKkADOvSABHa0bsYUxuQrT1ZHYiv7yYWbn5N/3yUwnoFpivfQEO+YStfVtQy
kCW0CNkyhIC8Hd379vVtZf2eLgGhlHDNudfJvZ/F29Rdsb1NjRoWb3qjXmUX0Ns3
T9Ee7UHbN1oQuL4C1+XtFTl0mG7/UtIC5vk6/LTRY7G0oqmcfIzG26STiP5Q4++m
72JQP9jv9pAZzVoYMcnuj4vkVJ3rKfUoQS6Ejz4Y1tXlBeU3iXvL0Pb6h5EDWf7L
iNbk60NT9Y/KSWwIaf8iTFeH5K+NcgT+JQOe0iFH930Nme7lCXf38vuzBIsSfX0=
=fcNC
-----END PGP SIGNATURE-----
