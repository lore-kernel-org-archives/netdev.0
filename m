From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Thu, 3 May 2012 11:31:10 +1000
Message-ID: <20120503113110.3eded43c5dc526a471c69dd2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__3_May_2012_11_31_10_+1000_eenyizu+U6djWlZZ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ashok Nagarajan <ashok@cozybit.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__3_May_2012_11_31_10_+1000_eenyizu+U6djWlZZ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
net/wireless/nl80211.c between commit 9360ffd18597 ("wireless: Stop using
NLA_PUT*()") from the net-next tree and commit 0a9b3782ef40 ("{nl,cfg,mac}
80211: Allow user to see/configure HT protection mode") from the
wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/wireless/nl80211.c
index d5005c5,859bd66..0000000
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@@ -3348,50 -3292,51 +3348,52 @@@ static int nl80211_get_mesh_config(stru
  	pinfoattr =3D nla_nest_start(msg, NL80211_ATTR_MESH_CONFIG);
  	if (!pinfoattr)
  		goto nla_put_failure;
 -	NLA_PUT_U32(msg, NL80211_ATTR_IFINDEX, dev->ifindex);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_RETRY_TIMEOUT,
 -			cur_params.dot11MeshRetryTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_CONFIRM_TIMEOUT,
 -			cur_params.dot11MeshConfirmTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HOLDING_TIMEOUT,
 -			cur_params.dot11MeshHoldingTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_MAX_PEER_LINKS,
 -			cur_params.dot11MeshMaxPeerLinks);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_MAX_RETRIES,
 -			cur_params.dot11MeshMaxRetries);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_TTL,
 -			cur_params.dot11MeshTTL);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_ELEMENT_TTL,
 -			cur_params.element_ttl);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_AUTO_OPEN_PLINKS,
 -			cur_params.auto_open_plinks);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_SYNC_OFFSET_MAX_NEIGHBOR,
 -			cur_params.dot11MeshNbrOffsetMaxNeighbor);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_HWMP_MAX_PREQ_RETRIES,
 -			cur_params.dot11MeshHWMPmaxPREQretries);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_PATH_REFRESH_TIME,
 -			cur_params.path_refresh_time);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_MIN_DISCOVERY_TIMEOUT,
 -			cur_params.min_discovery_timeout);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_HWMP_ACTIVE_PATH_TIMEOUT,
 -			cur_params.dot11MeshHWMPactivePathTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_PREQ_MIN_INTERVAL,
 -			cur_params.dot11MeshHWMPpreqMinInterval);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_PERR_MIN_INTERVAL,
 -			cur_params.dot11MeshHWMPperrMinInterval);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME,
 -			cur_params.dot11MeshHWMPnetDiameterTraversalTime);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_HWMP_ROOTMODE,
 -			cur_params.dot11MeshHWMPRootMode);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_RANN_INTERVAL,
 -			cur_params.dot11MeshHWMPRannInterval);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_GATE_ANNOUNCEMENTS,
 -			cur_params.dot11MeshGateAnnouncementProtocol);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_FORWARDING,
 -			cur_params.dot11MeshForwarding);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_RSSI_THRESHOLD,
 -			cur_params.rssi_threshold);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_HT_OPMODE,
 -			cur_params.ht_opmode);
 +	if (nla_put_u32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_RETRY_TIMEOUT,
 +			cur_params.dot11MeshRetryTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_CONFIRM_TIMEOUT,
 +			cur_params.dot11MeshConfirmTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HOLDING_TIMEOUT,
 +			cur_params.dot11MeshHoldingTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_MAX_PEER_LINKS,
 +			cur_params.dot11MeshMaxPeerLinks) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_MAX_RETRIES,
 +		       cur_params.dot11MeshMaxRetries) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_TTL,
 +		       cur_params.dot11MeshTTL) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_ELEMENT_TTL,
 +		       cur_params.element_ttl) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_AUTO_OPEN_PLINKS,
 +		       cur_params.auto_open_plinks) ||
 +	    nla_put_u32(msg, NL80211_MESHCONF_SYNC_OFFSET_MAX_NEIGHBOR,
 +			cur_params.dot11MeshNbrOffsetMaxNeighbor) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_HWMP_MAX_PREQ_RETRIES,
 +		       cur_params.dot11MeshHWMPmaxPREQretries) ||
 +	    nla_put_u32(msg, NL80211_MESHCONF_PATH_REFRESH_TIME,
 +			cur_params.path_refresh_time) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_MIN_DISCOVERY_TIMEOUT,
 +			cur_params.min_discovery_timeout) ||
 +	    nla_put_u32(msg, NL80211_MESHCONF_HWMP_ACTIVE_PATH_TIMEOUT,
 +			cur_params.dot11MeshHWMPactivePathTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_PREQ_MIN_INTERVAL,
 +			cur_params.dot11MeshHWMPpreqMinInterval) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_PERR_MIN_INTERVAL,
 +			cur_params.dot11MeshHWMPperrMinInterval) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME,
 +			cur_params.dot11MeshHWMPnetDiameterTraversalTime) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_HWMP_ROOTMODE,
 +		       cur_params.dot11MeshHWMPRootMode) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_RANN_INTERVAL,
 +			cur_params.dot11MeshHWMPRannInterval) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_GATE_ANNOUNCEMENTS,
 +		       cur_params.dot11MeshGateAnnouncementProtocol) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_FORWARDING,
 +		       cur_params.dot11MeshForwarding) ||
 +	    nla_put_u32(msg, NL80211_MESHCONF_RSSI_THRESHOLD,
- 			cur_params.rssi_threshold))
++			cur_params.rssi_threshold) ||
++	    nla_put_u32(msg, NL80211_MESHCONF_HT_OPMODE,
++			cur_params.ht_opmode))
 +		goto nla_put_failure;
  	nla_nest_end(msg, pinfoattr);
  	genlmsg_end(msg, hdr);
  	return genlmsg_reply(msg, info);

--Signature=_Thu__3_May_2012_11_31_10_+1000_eenyizu+U6djWlZZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPod/eAAoJEECxmPOUX5FEaSAP/20XC39SPAp7htMgy2UW7cvI
4glq0Lfpgjomv1xGGTr4k3AZuJi0Y0a0q9iFz/wTwAQHOtBuM7kd4IURLaOWIk3z
oYI1RqpNUnq2ysOUdlFTudS4nVM2HNZCeWFDjcxMjhvKnQ8J245RQjR3icsFL4ll
BpzHrd08xC+kyT4Fuujz8p3JYaqUEB3qgMDpy2h9LYhZZf3dKJblrBSB9AhaZh2J
dgSzo6AKT0+v6K7nUFLVzDi625MKA+w6eX6TPb+azdqzPdh/YdDWI/nQkM0AAQwM
3W8cyf1O4RKu84qEtY7HiVMk1m6Xa36SSSw/sgKmnJF6ghEgTZJQXVm7QF+dRRDl
lGvDBFkUGiSCx59ctLnURsok8S4dquZX1ObdIFvIl5cJgtFX40lFtUsJlRMIP51C
NUWzcZGkSnM1bkSZ3bM50TX4lRGB16mwq/82OvoLbm2hiH6YY7ogL5xyulipRyzH
q1ycX4CmvHVYISpBq7uZIN6hLtDJA/TSF7woEpssaOAQneE2wysw1rrvSOG7CSN2
nODNWTA1f6BNamZ2igewdbdEebamOT9VN2VTWsYU5wmQK5jqDOb/d4dp5BnpfKZl
hEVJml56xroK02FIs5ojKFvPHJN2JZf0wvikMUeYUVXBz2MPsSNH5rd9NnMv8aTf
Iaqg4nuwfUi2PR9s78ym
=2vnO
-----END PGP SIGNATURE-----

--Signature=_Thu__3_May_2012_11_31_10_+1000_eenyizu+U6djWlZZ--
