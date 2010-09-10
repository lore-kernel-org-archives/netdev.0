From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH net-next-2.6] ethtool: Complete kernel-doc comments for
 RX flow filter and hash control
Date: Thu, 09 Sep 2010 17:50:54 -0700
Message-ID: <1284079854.2803.7.camel@ppwaskie-mobl2>
References: <1283870488.2270.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature"; boundary="=-6mvOE1Z1Q/N8f/sbcCp2"
Cc: David Miller <davem@davemloft.net>,
	Santwona Behera <santwona.behera@sun.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	Dimitris Michailidis <dm@chelsio.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17835 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868Ab0IJAu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Sep 2010 20:50:56 -0400
In-Reply-To: <1283870488.2270.9.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6mvOE1Z1Q/N8f/sbcCp2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-09-07 at 07:41 -0700, Ben Hutchings wrote:
> There are now several interfaces within the ethtool API for getting
> and setting RX flow filtering and hashing behaviour, most of which are
> poorly documented.  This adds kernel-doc comments for all these
> interfaces, based on the existing incomplete comments and on the
> initial implementations.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Santwona, Peter,
>=20
> Please point out any errors and any information that should be added to
> the comments to explain the significant differences between the RXNFC
> and RXNTUPLE interfaces.

Thanks for putting this together.  I've just been buried with other
things, and haven't had a chance to do it.

I can comment on the ntuple interfaces.  See below.

> Ben.
>=20
>  include/linux/ethtool.h |   93 ++++++++++++++++++++++++++++++++++++++++-=
------
>  1 files changed, 80 insertions(+), 13 deletions(-)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 991269e..6bd8cf2 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -357,6 +357,14 @@ struct ethtool_usrip4_spec {
>  	__u8    proto;
>  };
> =20
> +/**
> + * struct ethtool_rx_flow_spec - specification for RX flow filter
> + * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
> + * @h_u: Flow fields to match (dependent on @flow_type)
> + * @m_u: Masks for flow field bits to be ignored
> + * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
> + * @location: Index of filter in hardware table
> + */
>  struct ethtool_rx_flow_spec {
>  	__u32		flow_type;
>  	union {
> @@ -369,32 +377,87 @@ struct ethtool_rx_flow_spec {
>  		struct ethtool_ether_spec		ether_spec;
>  		struct ethtool_usrip4_spec		usr_ip4_spec;
>  		__u8					hdata[64];
> -	} h_u, m_u; /* entry, mask */
> +	} h_u, m_u;
>  	__u64		ring_cookie;
>  	__u32		location;
>  };
> =20
> +/**
> + * struct ethtool_rxnfc - command to get or set RX flow classification r=
ules
> + * @cmd: Specific command number - %ETHTOOL_GRXFH, %ETHTOOL_SRXFH,
> + *	%ETHTOOL_GRXRINGS, %ETHTOOL_GRXCLSRLCNT, %ETHTOOL_GRXCLSRULE,
> + *	%ETHTOOL_GRXCLSRLALL, %ETHTOOL_SRXCLSRLDEL or %ETHTOOL_SRXCLSRLINS
> + * @flow_type: Type of flow to be affected, e.g. %TCP_V4_FLOW
> + * @data: Command-dependent value
> + * @fs: Flow filter specification
> + * @rule_cnt: Number of rules to be affected
> + * @rule_locs: Array of valid rule indices
> + *
> + * For %ETHTOOL_GRXFH and %ETHTOOL_SRXFH, @data is a bitmask indicating
> + * the fields included in the flow hash, e.g. %RXH_IP_SRC.  The followin=
g
> + * structure fields must not be used.
> + *
> + * For %ETHTOOL_GRXRINGS, @data is set to the number of RX rings/queues
> + * on return.
> + *
> + * For %ETHTOOL_GRXCLSRLCNT, @rule_cnt is set to the number of defined
> + * rules on return.
> + *
> + * For %ETHTOOL_GRXCLSRULE, @fs.@location specifies the index of an
> + * existing filter rule on entry and @fs contains the rule on return.
> + *
> + * For %ETHTOOL_GRXCLSRLALL, @rule_cnt specifies the array size of the
> + * user buffer for @rule_locs on entry.  On return, @data is the size
> + * of the filter table and @rule_locs contains the indices of the
> + * defined rules.
> + *
> + * For %ETHTOOL_SRXCLSRLINS, @fs specifies the filter rule to add or
> + * update.  @fs.@location specifies the index to use and must not be
> + * ignored.
> + *
> + * For %ETHTOOL_SRXCLSRLDEL, @fs.@location specifies the index of an
> + * existing filter rule on entry.
> + *
> + * Implementation of indexed classification rules generally requires a
> + * TCAM.
> + */
>  struct ethtool_rxnfc {
>  	__u32				cmd;
>  	__u32				flow_type;
> -	/* The rx flow hash value or the rule DB size */
>  	__u64				data;
> -	/* The following fields are not valid and must not be used for
> -	 * the ETHTOOL_{G,X}RXFH commands. */
>  	struct ethtool_rx_flow_spec	fs;
>  	__u32				rule_cnt;
>  	__u32				rule_locs[0];
>  };
> =20
> +/**
> + * struct ethtool_rxfh_indir - command to get or set RX flow hash indire=
ction
> + * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFH=
INDIR
> + * @size: On entry, the array size of the user buffer.  On return from
> + *	%ETHTOOL_GRXFHINDIR, the array size of the hardware indirection table=
.
> + * @ring_index: RX ring/queue index for each hash value
> + */
>  struct ethtool_rxfh_indir {
>  	__u32	cmd;
> -	/* On entry, this is the array size of the user buffer.  On
> -	 * return from ETHTOOL_GRXFHINDIR, this is the array size of
> -	 * the hardware indirection table. */
>  	__u32	size;
> -	__u32	ring_index[0];	/* ring/queue index for each hash value */
> +	__u32	ring_index[0];
>  };
> =20
> +/**
> + * struct ethtool_rx_ntuple_flow_spec - specification for RX flow filter
> + * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
> + * @h_u: Flow field values to match (dependent on @flow_type)
> + * @m_u: Masks for flow field value bits to be ignored
> + * @vlan_tag: VLAN tag to match
> + * @vlan_tag_mask: Mask for VLAN tag bits to be ignored
> + * @data: Driver-dependent data to match
> + * @data_mask: Mask for driver-dependent data bits to be ignored
> + * @action: RX ring/queue index to deliver to (non-negative) or other ac=
tion
> + *	(negative)

The negative value is typically to drop the flow.  That could be added
as a brief example of "other action."

> + *
> + * Zero values in @h_u may be ignored, as if all the corresponding
> + * mask bits were set.
> + */
>  struct ethtool_rx_ntuple_flow_spec {
>  	__u32		 flow_type;
>  	union {
> @@ -407,18 +470,22 @@ struct ethtool_rx_ntuple_flow_spec {
>  		struct ethtool_ether_spec		ether_spec;
>  		struct ethtool_usrip4_spec		usr_ip4_spec;
>  		__u8					hdata[64];
> -	} h_u, m_u; /* entry, mask */
> +	} h_u, m_u;
> =20
>  	__u16	        vlan_tag;
>  	__u16	        vlan_tag_mask;
> -	__u64		data;      /* user-defined flow spec data */
> -	__u64		data_mask; /* user-defined flow spec mask */
> +	__u64		data;
> +	__u64		data_mask;
> =20
> -	/* signed to distinguish between queue and actions (DROP) */
>  	__s32		action;
> -#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
> +#define ETHTOOL_RXNTUPLE_ACTION_DROP -1		/* drop packet */
>  };
> =20
> +/**
> + * struct ethtool_rx_ntuple - command to get or set RX flow filter
> + * @cmd: Specific command number - %ETHTOOL_GRXNTUPLE or %ETHTOOL_SRXNTU=
PLE
> + * @fs: Flow filter specification
> + */
>  struct ethtool_rx_ntuple {
>  	__u32					cmd;
>  	struct ethtool_rx_ntuple_flow_spec	fs;

Everything else in the ntuple section looks fine to me.

--=20
Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
LAN Access Division, Intel Corporation

--=-6mvOE1Z1Q/N8f/sbcCp2
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIPAjCCAz0w
ggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UEChMHRXF1
aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTA2
MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVs
IENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kgQ0EwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATDIsV2xDyt
30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUjZzTZFq2N
4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZvuSQ0E11y
YL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4lz36wOdN
Zn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+iC1HawJd
AgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0Vgaj7TdU
DDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3NlY3VyZWNh
LmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69tOkIP4Sg
DJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3jMfr900fX
ZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYSCKYgAAAAAACDAN
BgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24x
JzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUxOTI3MjZa
Fw0xNTA1MTUxOTM3MjZaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jwb3JhdGlv
bjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQjCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAKQEM1Wn9TU9vc9C+/Tc7KB+eiYElmrcEWE32WUdHvWG+IcQ
HVQsikTmMyKKojNLw2B5s6Iekc8ivDo/wCfjZzX9JyftMnc+AArc0la87Olybzm8K9jXEfTBvTnU
SFSiI9ZYefITdiUgqlAFuljFZEHYKYtLuhrRacpmQfP4mV63NKdc2bT804HRf6YptZFa4k6YN94z
lrGNrBuQQ74WFzz/jLBusbUpEkro6Mu/ZYFOFWQrV9lBhF9Ruk8yN+3N6n9fUo/qBigiF2kEn9xV
h1ykl7SCGL2jBUkXx4qgV27a6Si8lRRdgrHGtN/HWnSWlLXTH5l575H4Lq++77OFv38CAwEAAaOC
AlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFA7GKvdZsggQkCVvw939imYxMCvFMAsG
A1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQ5oFY2ekKQ/5Kt
im+VdMeSWb4QWTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdv
qNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3klMjBDQS5j
cmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIw
RXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYI
KwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcwAoZgaHR0
cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwl
MjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCx
tQEHchVQhXyjEqtMVUMe6gkmPsIczHxSeqNbo9dsD+6xbT65JT+oYgpIAtfEsYXeUJu1cChqpb22
U5bMAz7eaQcW5bzefufWvA6lg2048B8oczBj/q+5P5NpYrUO8jOmN4jTjfJq3ElZ7yFWpy7rB3Vm
/aN6ATYqWfMbS/xfh+JCxmH3droUmMJI0/aZJHsLtjbjFnNsHDNrJZX1vxlM78Lb1hjskTENPmhb
VbfTj5i/ZGnhv4tmI8QZPCNtcegXJrfhRl2D9bWpdTOPrWiLDUqzy1Z6KL7TcOS/PCl8RHCJXkPa
u/thTQCpIoDa2+c+3XA++gRTfAQ4svTO260NMIIGLzCCBRegAwIBAgIKf0es/QABAABRFTANBgkq
hkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0IwHhcNMTAwNDA5MDgyNzMw
WhcNMTMwMzI0MDgyNzMwWjBRMR8wHQYDVQQDExZXYXNraWV3aWN6IEpyLCBQZXRlciBQMS4wLAYJ
KoZIhvcNAQkBFh9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAxNvzDG+qS7UFSaYiqMqQr7exXHirCVe1tapLZoFlJZLPfqZsBsAA
UqARnY+v3RQj3WDmoIOtTMHxtnmo4pd5UXrsk+PraedGAilso9tkfp5ZjRjZo9LL06AZzjiBVfAx
gvyxMPsoKhdfFijzqSJRpc12kB662PAJWfyJO+f6lg5+Cd4KgRVGrpGI4bvBKEVGMeOqwD+kcVti
wRcqNygx35GqdcpJCCJqOSAJsLI3DR7tDvATeNzsasweaHgWonaK4D6qaHkoGx4VHknC6uNn/FK/
wXtFbXkeOrnRGJIzaZNsOBVhTou9w3NYU1EjuK75hZJ4Fd4/r1gHafxWD+VzrwIDAQABo4IDAjCC
Av4wCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWO
n1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFLtB44dRTSgY1071RY+nMiKRkn1PMB8GA1Ud
IwQYMBaAFA7GKvdZsggQkCVvw939imYxMCvFMIHPBgNVHR8EgccwgcQwgcGggb6ggbuGV2h0dHA6
Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUy
MElzc3VpbmclMjBDQSUyMDNCKDEpLmNybIZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20v
cmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIw
M0IoMSkuY3JsMIH1BggrBgEFBQcBAQSB6DCB5TBsBggrBgEFBQcwAoZgaHR0cDovL3d3dy5pbnRl
bC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIw
SXNzdWluZyUyMENBJTIwM0IoMSkuY3J0MHUGCCsGAQUFBzAChmlodHRwOi8vY2VydGlmaWNhdGVz
LmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFz
aWMlMjBJc3N1aW5nJTIwQ0ElMjAzQigxKS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQB
gjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsGA1UdEQRU
MFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tgR9wZXRl
ci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQBYea1KThIl9gNf
1uIob1trWtsthhWAXsdUu1V+gl10RBChuM4okZccJf1JXItFA2z7J2UR4cu/tRZBRFartVPhGBjK
ntLofxsaW7wwzfsinbNy30gHGShG83XDADdGUteL8PmupDcDf/MtbRIlfjEknLiuOnrM25WVajtB
3fB1pOA2jmLaaNmasza9ordaD3afJD3IWr/Zj+aevMu4zrKzwdOZqBZW1J1Qc7uog8Mn+mm+wRMm
EY0z7VFdjsZjJH9EQA0UbF1aYcshv0a/M2deKN9TdYuJ1eTKRSZdzSiRG5w75xujFMYZgo4ETlu1
Behgey1jvJiyWdOsPt7at08QMYIB6jCCAeYCAQEwZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMR
SW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vpbmcg
Q0EgM0ICCn9HrP0AAQAAURUwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTEwMDkxMDAwNTA1NFowIwYJKoZIhvcNAQkEMRYEFP/uAJx1jcLeIpGR
2PjJec2V8EeXMA0GCSqGSIb3DQEBAQUABIIBAE/M59RroWrIVZNnacaelDpU3NVZ0mr/Bln2C7L2
ODl3xJris+R4LkvtiJbtvlU5ANOOT63cjkslTgQLxab1jaTsNPmgZZXUlvoMV75D4Y8+wqY2Ioq1
WAEE744yEcoNaTnguQ5PIxqqeLsYhveCgiR2htGVuuIIXg/lakYxTlX61gK9q9LeWFaphyDFCSEs
qFQw/6BNauBNFSTTqnxNQS2iCIkmYp3jxG1dEZ722+ERIC+fCQi0Kj4rJVOM0Mz9b16xld59UfhH
k+y+iqnkssYcaTzOwUEaQ7bQKhv4HeBqhwkMAMrfkwBl0W78ZRhYrpv6FgMpS5BAPz5YY/wS55oA
AAAAAAA=


--=-6mvOE1Z1Q/N8f/sbcCp2--

