From: "Gnome42 Gnome42" <gnome42@gmail.com>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Fri, 8 Sep 2006 16:32:39 -0400
Message-ID: <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>
	 <4501CA01.3050904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:40209 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751210AbWIHUcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 16:32:41 -0400
Received: by py-out-1112.google.com with SMTP id t32so928061pyc
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2006 13:32:40 -0700 (PDT)
To: "Patrick McHardy" <kaber@trash.net>
In-Reply-To: <4501CA01.3050904@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/8/06, Patrick McHardy <kaber@trash.net> wrote:
> Gnome42 Gnome42 wrote:

> Can you see the decrypted packets on the incoming interface on the
> other side?

No, not the decrypted ones only the encrypted ones. I never see the
decrypted packets. ( I should see them twice right? Once encrypted and
once decrypted?)

> Please post your policies and related SAs from both sides.
> Are you using NAT, iptables or anything like that?

(Beware, I am not knowledgeable about IPSec :)

I am testing this between my workstation and my linux/firewall/nat box
with adsl. So encrypted on my local lan only.

The firewall box is using iptables and is natting for me but the ipsec
traffic is just local and is not natted. I am testing roadwarrior
mode, with the firewall as the responder. No iptables/NAT on my
workstation. I have allowed protocols 50/51 and udp 500 and it works
well with other kernels including 2.6.18-rc5, so I think the iptables
stuff is OK.

On my workstation(34.34.36.1) I use:
spdadd 34.34.36.1 206.207.0.0/16 any -P out ipsec
           esp/tunnel/34.34.36.1-34.34.36.6/use;
spdadd 206.207.0.0/16 34.34.36.1 any -P in ipsec
           esp/tunnel/34.34.36.6-34.34.36.1/use;

and on the firewall:
remote anonymous {
        exchange_mode aggressive,main;
        passive on;
        my_identifier fqdn "blah1";
        peers_identifier fqdn "blah2";
        verify_identifier on;
        proposal {
                encryption_algorithm aes;
                hash_algorithm md5;
                authentication_method pre_shared_key;
                dh_group modp1024;
        }
        generate_policy on;
}
sainfo anonymous {
        pfs_group modp1024;
        encryption_algorithm aes;
        authentication_algorithm hmac_md5;
        compression_algorithm deflate;
}

... or did you mean dumps from setkey -D[P]?
