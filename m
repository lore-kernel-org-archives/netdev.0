From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH] net/vlan: withdraw VLAN ID attribute from GVRP on VLAN
 device stop
Date: Mon, 26 Mar 2012 11:50:16 -0400
Message-ID: <4F709038.20107@ll.mit.edu>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
 <1332715437-16278-2-git-send-email-david.ward@ll.mit.edu>
 <4F705329.10208@dti2.net> <4F707163.2000209@ll.mit.edu>
 <4F7087CA.5010804@dti2.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms040806030003020807020904"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "jorge@dti2.net" <jorge@dti2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:35534 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932489Ab2CZPuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 11:50:23 -0400
In-Reply-To: <4F7087CA.5010804@dti2.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms040806030003020807020904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On 26/03/12 11:14, Jorge Boncompte [DTI2] wrote:
> El 26/03/2012 15:38, Ward, David - 0663 - MITLL escribi=F3:
>> On 26/03/12 07:29, Jorge Boncompte [DTI2] wrote:
>>> El 26/03/2012 0:43, David Ward escribi=F3:
>>>> When a VLAN device is stopped which has VLAN_FLAG_GVRP set, the VLAN=

>>>> ID attribute that was previously declared by GVRP must be withdrawn.=

>>>>
>>> 	Hmm, maybe I am missing something but I think it only makes sense to=
 withdrawn
>>> the attribute when you delete the interface, and vlan_dev_stop() it's=
 called if
>>> you just put the interface down. It's better for the network converge=
nce to not
>>> signal the switches just for this. IMHO.
>> If I bring a VLAN interface down, then I stop participating in the
>> VLAN.  If my NIC still receives traffic for the VLAN, I drop it.  So t=
o
>> remove unnecessary load on the (potentially shared) network link and
>> remove unnecessary local processing by the kernel of packets I know I =
am
>> going to drop, I should tell the switch that I am no longer interested=

>> in receiving the VLAN traffic.  Which is the whole point of GVRP.  Rig=
ht?
> 	In the non-GVRP case, as far as i can see, you still receive the traff=
ic for
> that VLAN and the kernel drops it.
But this is why GVRP is advantageous.  I don't have to have a static=20
configuration on the switch for the VLANs I am participating in, and so=20
I only receive VLAN traffic when the VLAN interface is active and I=20
would actually process it.

>   Maybe is that I think that a downed interface
> it's more a transient state, and administratively choosen one. If you d=
on't want
> to participate in that VLAN, you always can disable GVRP on it or delet=
e the
> interface.
>
>> In any case, we currently register the attribute when the interface is=

>> brought up, not when it is created.
> 	And that makes sense to me, if you have never uped the interface you h=
ave never
> participated in that VLAN.

If I create an interface that is initially down, then bring it up, and=20
finally bring it back down, I think it should return to the state it was =

in initially.  So in my opinion, either the GVRP attribute should exist=20
while the interface is down, or it shouldn't.

For comparison, bringing a physical NIC interface down causes the other=20
end of a point-to-point Ethernet link to sense "no carrier", which could =

trigger a topology change on the switch.  So to me, it's semantically=20
the same that bringing a VLAN interface down could trigger a topology=20
change on the switch.

If your concern is about the effect on the network switching topology of =

brief periods in which you bring the VLAN interface down (in order to=20
move it to another namespace), keep in mind that the default LeaveTimer=20
is 600 ms so the switch wouldn't propagate any topology changes unless=20
you don't bring the interface back up by then.  Or you could consider=20
changing this timer on your switch.

David

>>   However we do it, the attribute
>> declaration/withdrawal should be symmetric.
>>
>>>> Signed-off-by: David Ward<david.ward@ll.mit.edu>
>>>> ---
>>>>    net/8021q/vlan_dev.c |    3 +++
>>>>    1 files changed, 3 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>>>> index 9988d4a..df86dd0 100644
>>>> --- a/net/8021q/vlan_dev.c
>>>> +++ b/net/8021q/vlan_dev.c
>>>> @@ -319,6 +319,9 @@ static int vlan_dev_stop(struct net_device *dev)=

>>>>    	struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
>>>>    	struct net_device *real_dev =3D vlan->real_dev;
>>>>
>>>> +	if (vlan->flags&   VLAN_FLAG_GVRP)
>>>> +		vlan_gvrp_request_leave(dev);
>>>> +
>>>>    	dev_mc_unsync(real_dev, dev);
>>>>    	dev_uc_unsync(real_dev, dev);
>>>>    	if (dev->flags&   IFF_ALLMULTI)--
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>


--=20
David Ward, Associate Staff
Wideband Tactical Networking Group
MIT Lincoln Laboratory
Office: 781-981-4266
Mobile: 781-999-1925
Fax: 781-981-4583



--------------ms040806030003020807020904
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
h4HfOoHsBGFUMYQGMnL48b9p9mXwrJXo/WKFGe8l9+dLoOWMdZ+dvKQva9kEAAOnbIZ2xXSi
7EAz0AD/QPSwUnf8MYIDKjCCAyYCAQEwXzBRMQswCQYDVQQGEwJVUzEfMB0GA1UEChMWTUlU
IExpbmNvbG4gTGFib3JhdG9yeTEMMAoGA1UECxMDUEtJMRMwEQYDVQQDEwpNSVRMTCBDQS0y
Agodmr+JAAAAACaLMAkGBSsOAwIaBQCgggGgMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTEyMDMyNjE1NTAxNlowIwYJKoZIhvcNAQkEMRYEFNPRJ0rEZTsr
sCsElE2UMge39klXMF8GCSqGSIb3DQEJDzFSMFAwCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMH
MA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIB
KDBuBgkrBgEEAYI3EAQxYTBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQgTGluY29s
biBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTICCh2aFRcA
AAAAJoowcAYLKoZIhvcNAQkQAgsxYaBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQg
TGluY29sbiBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTIC
Ch2aFRcAAAAAJoowDQYJKoZIhvcNAQEBBQAEggEAc0+7njgZJazrK8m519EszgrF4rBymEJT
unCLt6U+lCTpCoVL5Eg9clTTcum3ZzDAguy+u+i63uWQKij3tVEimdB/S9v+1pnqeQgnSg1F
aGH477xPELYAtqmofjqbFHuGAFi7uppwsuA2urY8gHA+SW9rHQFgFSR7/pJc0FO4D2WdSX0Z
kpUbE1uHK4OyIR1/Q6DPxFnDJhVGcj+AceoPY7wUcBlzxcR5QkGJF2o7BCz5Z4ZQKP5+9NRI
I9LUQWWt6ExSLWZnJddNnPuvET/jaS8Zzg0hUMOOn9v1c6YustFC7RcU+OyQj2OXyOxB79/C
7giTR09kE91rdhQ50s7mAgAAAAAAAA==
--------------ms040806030003020807020904--
