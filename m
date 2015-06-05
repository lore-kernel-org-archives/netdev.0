From: Jaeden Amero <jaeden.amero@ni.com>
Subject: Re: [PATCH v3 3/3] net/phy: micrel: Center FLP timing at 16ms
Date: Fri, 05 Jun 2015 17:50:15 -0500
Message-ID: <557227A7.2080603@ni.com>
References: <1433544046-17595-1-git-send-email-jaeden.amero@ni.com> <1433544046-17595-4-git-send-email-jaeden.amero@ni.com> <5572261A.1070801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5572261A.1070801@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/2015 05:43 PM, Florian Fainelli wrote:
> On 05/06/15 15:40, Jaeden Amero wrote:
>> Link failures have been observed when using the KSZ9031 with HP 1810=
-8G
>> and HP 1910-8G network switches. Center the FLP timing at 16ms to he=
lp
>> avoid intermittent link failures.
>>
>> From the KSZ9031RNX and KSZ9031MNX data sheets revision 2.2, section
>> "Auto-Negotiation Timing":
>> 	The KSZ9031[RNX or MNX] Fast Link Pulse (FLP) burst-to-burst
>> 	transmit timing for Auto-Negotiation defaults to 8ms. IEEE 802.3
>> 	Standard specifies this timing to be 16ms +/-8ms. Some PHY link
>> 	partners need to receive the FLP with 16ms centered timing;
>> 	otherwise, there can be intermittent link failures and long
>> 	link-up times.
>>
>> 	After KSZ9031[RNX or MNX] power-up/reset, program the following
>> 	register sequence to set the FLP timing to 16ms
>>
>> 	Write Register Dh =3D 0x0000 // Set up register address for MMD =E2=
=80=93 Device Address 0h
>> 	Write Register Eh =3D 0x0004 // Select Register 4h of MMD =E2=80=93=
 Device Address 0h
>> 	Write Register Dh =3D 0x4000 // Select register data for MMD =E2=80=
=93 Device Address 0h, Register 4h
>> 	Write Register Eh =3D 0x0006 // Write value 0x0006 to MMD =E2=80=93=
 Device Address 0h, Register 4h
>> 	Write Register Dh =3D 0x0000 // Set up register address for MMD =E2=
=80=93 Device Address 0h
>> 	Write Register Eh =3D 0x0003 // Select Register 3h of MMD =E2=80=93=
 Device Address 0h
>> 	Write Register Dh =3D 0x4000 // Select register data for MMD =E2=80=
=93 Device Address 0h, Register 3h
>> 	Write Register Eh =3D 0x1A80 // Write value 0x1A80 to MMD =E2=80=93=
 Device Address 0h, Register 3h
>> 	Write Register 0h, Bit [9] =3D 1 // Restart Auto-Negotiation
>=20
> Quoting a portion of the data-sheet on how to do this programming is
> very strange considering that the code is going to be the reference, =
not
> the commit message.

I included it for lack of something better to quote that explained
which values to set when. I'd be happy to revise the message as this
appears too strange.

> Other than that, this looks reasonable.

Thanks very much for the review.

Cheers,
Jaeden
