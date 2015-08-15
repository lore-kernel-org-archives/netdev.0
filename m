From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 04/11] udp: Handle VRF device in sendmsg
Date: Fri, 14 Aug 2015 23:29:53 -0600
Message-ID: <55CECE51.1050608@cumulusnetworks.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>	<1439499551-90231-5-git-send-email-dsa@cumulusnetworks.com>	<CALx6S34ymDARX9EjCUZtHzd=+iUpry5WbCR4axXSDFBhVSTDUw@mail.gmail.com>	<CAJmoNQGorXyd_vjigkJGntdNMmwMhL8AUfxA+s98uaY9ia73Gw@mail.gmail.com> <CALx6S36MAQRgEqcJbTO_m6eMEAzoJ6k3o67z7EgLa3BjUg6MbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, svaidya@brocade.com
To: Tom Herbert <tom@herbertland.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38405 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbbHOF34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2015 01:29:56 -0400
Received: by igfj19 with SMTP id j19so25108333igf.1
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 22:29:55 -0700 (PDT)
In-Reply-To: <CALx6S36MAQRgEqcJbTO_m6eMEAzoJ6k3o67z7EgLa3BjUg6MbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/14/15 9:16 PM, Tom Herbert wrote:
> At least collect this code into one (static inline) function to better
> minimize the code churn in udp. If this is general functionality that
> can be used by other drivers then abstract it out as such. Also, if
> the VRF driver is not configured it seems like this code should
> compiled out. As it stands now "if (netif_index_is_vrf(net, ipc.oif))
> {" adds a conditional to every call of udp_sendmsg rather or not we
> are using VRF :-(.

Sure. I wanted to make sure all of the VRF related changes compiled out 
when the VRF driver is not enabled. This one slipped by me. I'll send a 
patch next week along with a couple of others per Eric D's comments.

David
