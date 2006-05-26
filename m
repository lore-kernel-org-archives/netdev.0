From: "Mikel L. Matthews" <mikel@argus-systems.com>
Subject: Re: [RFC 0/4] NetLabel
Date: Fri, 26 May 2006 11:09:08 -0500
Message-ID: <44772824.6090505@argus-systems.com>
References: <44760E29.4070407@hp.com> <Pine.LNX.4.64.0605251938360.27473@d.namei> <44771EFB.6030203@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.argus-systems.com ([66.209.209.162]:36861 "EHLO
	ranger.argus-systems.com") by vger.kernel.org with ESMTP
	id S1750940AbWEZQJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 12:09:16 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <44771EFB.6030203@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:
> James Morris wrote:
>> On Thu, 25 May 2006, Paul Moore wrote:
>>> This patch introduces a new kernel feature designed to support labeled
>>> networking protocols such as RIPSO and CIPSO.  These protocols are required to
>>> interoperate with existing "trusted" operating systems such as Trusted
>>> Solaris.
>> A few initial comments.
>>
>> - Did you decide that you definitely need to verify labels on fragments?  
>>
>> I can see the code's been added to do that, but wonder about a comment 
>> made during earlier discussion that mislabeled fragments could only come 
>> from a misbehaving trusted system.  What is the threat model here?
>>
> 
> This is one part of the patch that I really don't have a strong feeling
> for either way.  There was some concern on the LSM list that not
> checking the fragment options might be an issue so I added some code to
> check the fragment options.  Personally I think we are probably okay
> without it as the un-autenticated/un-verified nature of these labeling
> protocols more or less requires either a trusted network/hosts.
> 
> If the community decides that this check is not required then I can
> simply drop all of the changes in ip_fragment.c.

If you state you are labeling session packets (tcp or udp), that would 
lead one to believe all packets are labeled (including fragments). Based 
on our past evaluations I don't think non-labeled fragments would make 
it through an evaluation if CIPSO/RIPSO  were part of the TOE/security 
Target.

> 
>> - Can you explain how module loading and module refcounting for these 
>> modules work?  (e.g. what causes netlabel_cipso_v4 to be loaded, is it 
>> always safe to unload if the refcount is zero?)
> 


-- 
Thanks,
Mike

Mikel L. Matthews
Chief Technology Officer
Innovative Security Systems, Inc.
(dba Argus Systems Group)
1809 Woodfield Dr.
Savoy IL 61874
+1-217-355-6308
www.argus-systems.com
