From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Prevent deletion of a bond, or the last slave
 from a bond, with active usage.
Date: Fri, 9 Sep 2016 08:38:02 +0200
Message-ID: <20160909063801.GA1856@nanopsycho.orion>
References: <1473154470-15087-1-git-send-email-jasminder.kaur@hpe.com>
 <4691.1473174539@famine>
 <AT5PR84MB01151743CF3182FAFC91D7F98AFB0@AT5PR84MB0115.NAMPRD84.PROD.OUTLOOK.COM>
 <20160908151705.GD1842@nanopsycho.orion>
 <AT5PR84MB011502FB43B95AF91ADF6F0E8AFB0@AT5PR84MB0115.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
        "vfalico@gmail.com" <vfalico@gmail.com>,
        "gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Gurunath, Vasundhara (STSD)" <vasundhara.gurunath@hpe.com>,
        "Arackal, Paulose Kuriakose (STSD)"
        <paulose.kuriakose.arackal@hpe.com>
To: "Kaur, Jasminder (STSD)" <jasminder.kaur@hpe.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AT5PR84MB011502FB43B95AF91ADF6F0E8AFB0@AT5PR84MB0115.NAMPRD84.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Sep 08, 2016 at 06:32:02PM CEST, jasminder.kaur@hpe.com wrote:
>>                The issue of interfaces being arbitrarily changed or deleted is not specific to bonding, and could affect any networking device (physical or virtual).  Thus, if a facility such as this is to be provided, it should be generic, not specific to bonding.
>
>>
>
>>
>
>>
>
>>                Separately, I'm not sure I see the value of such an option.
>
>>
>
>>Other than administrator error, I'm not sure when bonds (or other
>
>>
>
>>interfaces) would be randomly deleted.  Are you seeing that happening?
>
>>
>
>>
>
>>
>
>>                Also, this patch does not prevent other errors or malicious change, e.g., "ip link set bondX down" or "ip addr del 1.2.3.4/24" would still cause the service disruption you're trying to avoid.
>
>>
>
>>
>
>>
>
>>                And, lastly, what Jiri said: use netlink for new bonding functionality, not sysfs.
>
>>
>
>
>
>Re-sending my response as per Jiri's input to avoid top-posting.. Hope this is fine.
>
>
>
>Hi Jay,  Hi Jiri,
>
>
>
>Thank you for your inputs.
>
>
>
>Some of the requests we got for such preventive checks are from Admins working on large scale up systems with multiple NICs, FlexNICs and IP addresses.
>
>§  One use case for these checks is to give an alert, in case of any accidental removals owing to operator errors on large configurations.
>
>§  Another use case is during online maintenance activities such as dynamic patching or a driver load/unload operation.  Admin's would
>
>shut down applications and delete affected interfaces  before unload of a driver. They would prefer to get an alert during delete operation
>
>in case some usages linger around.


If admin is stupid and shoots himself in a foot, it's his problem.
Kernel's work is not to babysit him.

Stop wasting the time.


>
>Such alerts are more useful in Cluster configurations, Network Attached Storage( NAS) configurations, VM configurations with Guests, etc.
>
>
>
>So these were mainly the situations that prompted us to add such checks in delete paths.
>
>True these checks are not comprehensive for all use cases, we would like to extend this if it can cover more scenarios.
>
>
>
>sysfs based use cases were the ones we noticed for bond/slave configurations. Do you suggest other CLI's such as  “ip link” is more commonly used ?
>
>Possibly if these checks are rearranged a bit in code, multiple such CLI interfaces can be covered ? Please let us know.
>
>
>
>Thanks & Regards,
>
>Jasminder
>
>
>
>
>
>
>
>
