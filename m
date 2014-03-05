From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH (net.git) 2/4] stmmac: fix and better tune the default
 buffer sizes
Date: Wed, 5 Mar 2014 09:33:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D14A3@AcuExch.aculab.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com>
 <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CC945@AcuExch.aculab.com>
 <530F3784.5050304@st.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CCBB2@AcuExch.aculab.com>
 <530F4389.8060309@st.com> <53157ED1.2010505@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56911 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753810AbaCEJde convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 04:33:34 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12083-02 for <netdev@vger.kernel.org>;
 Wed,  5 Mar 2014 09:33:33 +0000 (GMT)
In-Reply-To: <53157ED1.2010505@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO 
> Hello David
> 
> Sorry, can you tell me what is the final your opinion about
> this patch?
> 
> I think that it not good to keep 4KiB as default and your main concern
> was about the default buffer size that depended on VLAN ifconfig.
> 
> So I could adopt 1536bytes as default and remove ifdef.

If the rx buffer size has to match the mtu then the minimum
size needs to be that for non-vlan packets.

OTOH if the rx buffer size only has to be 'long enough' and
a frame length check is done in software then you can always
use the vlan length and save reconfig is someone enables vlans.

My real concern was that you were setting the minimum buffer
size based on a vlan config option - which really didn't seem
right at all.

	David
